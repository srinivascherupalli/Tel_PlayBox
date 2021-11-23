/******************************************************************************************
 * Author	   : Telstra
 Change Version History
Version No	Author 			                Date                 Change Description
1           Pallavi D               23/06/2020           New - Generic UIPlugin file for all the UIevents
2.          Shubhi                  26/08/2020           RedemptionsUpdate post upgrade and nguc generate net price fix
3.          Pallavi/Shubhi          29/08/2020           Production defect fix for NGUC reserveNumber button 
4.          Gnana                   01/09/2020           PRM Duplicate menu fix for backToBasketInternal button
5.          Gnana                   04/09/2020           EDGE-155982 - PRM MAC Issue - Basket url fix on backToBasketInternal
6.          shubhi					07/09/2020           
7.          Gnana                   10/09/2020    	     EDGE-176222  Back to basket reditection url fix.
8.         Manuga Kale				11/09/2020		     EDGE-165017 Enable CS button on Solution Console
9.         Aarathi                  17/09/2020           EDGE-172045 Change link for Partner in View Offer Information button
10.        Jawahar                  24/09/2020            INC000093780730 Stock Check Button fix.
11.	    Pallavi/Pranit			3-10-2020			Refactored
12.	    Aman Soni				13-10-2020			Transition Device Sync Functionality for EDGE-173469
13.         Shresth					10/19/2020		     DPG-2319
12.         Shresth					10/19/2020		     DPG-2319
13.         Kamlesh                 28/10/2020           EDGE-185639 View button changed to View and Update for NGUCRateCardButton                       
14.	    Aman Soni				13-10-2020			Transition Device Sync Functionality for EDGE-173469
15.         Shresth					10/19/2020		     DPG-2319
16.         Shubhi					19/11/2020			EDGE-185011
17.         Payal                   24/11/2020           EDGE-189788,EDGE-178214 : Added TMDM Rate Card related changes and MS Rate Card related changes                    
18.         Krunal/Shresth          22/12/2020           Search - "//Replace /apex/(shresth)" - INC000094661970
19.         Payal                   29/12/2020           Updated URL for PRM users for NGUC,TMDM and MS according to INC000094661970
20. 	    Lalit					28/10/2020           DPG-3110 RateCard matrix for SDWAN 
21.	    shubhi					08/01/2020			 EDGE-198439
22.	    Aman Soni			    19/01/2021			 EDGE-191076
23.	    Aman Soni			    25/01/2021			 EDGE-191077/ EDGE-194029
24.	    Shubhi					25/01/2021		 EDGE-170016	
25.         Vishal Arbune           02/02/2021           EDGE-190327 Partner users are able to view TPC landing page on click "View Offer Information" button
26	    Shubhi					24/02/2021			 Edge-152456
27. 		Mahima Gandhe		    26/02/2021		     DPG-3889, 4083

28.         Gokul                   10/03/2021           EDGE-205510 : Updated Json Attributes to use value instead of displayValue
26	    Shubhi					24/02/2021			 Edge-152456
27. 		Mahima Gandhe		    26/02/2021		     DPG-3889, 4083

28.         Shubhi					15/03/2021			 EDGE-204313 chown ux incoming bakset	
29.         Gokul                   10/03/2021           EDGE-205510 : Updated Json Attributes to use value instead of displayValue
30.         shubhi V 		 7/05/2021                 review commments implemnted                    
31.	 	Pawan Singh	    11-08-2021		DIGI-5648: replacing Telstra collaboration to Adaptive collaboration
32.     Mukta Wadhwani  22-09-2021      INC000097102981 fix
33.	 	Monali M	    10-09-2021		DIGI-5561: RateCard matrix for Lifecycle Management 
34.          Vivek              09/26/2021       DIGI-14126
34.		vasu
35.     Ronak Mandhanya    13-10-2021     Digi-33119  Name changes for AMMS
36.     Pooja Bhat      8-10-2021       DIGI-8814 Adaptive Networks navigate to Site Record Page on click of link View Site Details
37.		Murugula Srinivasarao	29-10-2021	  DIGI-32173 - Enable Sales incentives for DMS.
*******************/
//var solution = null;

var NGUC_OFFER_NAME = 'Adaptive Collaboration'; //DIGI-5648
var NGUC_TENANCY_OFFER_NAME  = 'Adaptive Collaboration Tenancy'; // DIGI-5648
var mapSolLinks = {
	"Managed Services": {
		"Managed Services": { TenancyButton: "Select Tenancies" },
		"Mobility Platform Management": { tmdmRateCardButton: "View Rate Card" },
		"User Support": { endUserSupportRateCardButton: "View Rate Card" }
	},
	"Corporate Mobile Plus": { "Corporate Mobile Plus": { viewDiscounts: "View All" }, "Mobile Subscription": { viewDiscounts: "View All" } },
	// DIGI-5648
	// "Telstra Collaboration": {
	[NGUC_OFFER_NAME] : {
		"Business Calling": { NGUCRateCardButton: "View and Update" },//EDGE-185639
		Devices: { viewDiscounts: "View All" }
	},
	"IoT solutions": {
		"IoT solutions": { IoTRateCardButton: "View" }
	},
    "IoT Plans": {
		"IoT Plans": { IoTPlansRateCardButton: "View" }
	},
	"Telstra Mobile Device Management - VMware" : {
		"Platform" :{TMDMRateCard: "View and Update"} //EDGE-189788
	},
	"Adaptive Mobility Managed Services" : {
		"Endpoint Management - Platform Management" : {tmdmRateCardButton : "View and Update"}, //DIGI-809 name change,DIGI-33119
		"Endpoint Management - User Support" :{endUserSupportRateCardButton : "View and Update"} //DIGI-809 name change
	}, //Added as a part of EDGE-17821
    "Adaptive Mobility Managed Services Modular - Endpoint Lifecycle" : {
		"Endpoint Lifecycle" : {LifecycleRateCard: "View and Update"}
	}, //Added as a part of DIGI-5561
    "Adaptive Networks": { //Start: DIGI-8814
		"Adaptive Networks": { SiteDetails : "View Site Details &nbsp; <img width='13px' height='13px' style='margin-bottom: auto;' src=" + window.location.origin +  "/resource/"+ (new Date()).getTime() + "/Redirect_Icon >"}
	},   //End: DIGI-8814
	"Digital Managed Service" : {
		"DMS Product" :{DMSRateCard: "View and Update"} // DIGI-32173 - Enable Sales incentives for DMS.
	}
};
if (!CS || !CS.SM) {
	throw Error("Solution Console Api not loaded?");
}
window.document.addEventListener("SolutionConsoleReady", async function () {
	window.basketId = null;
	window.basketId = await CS.SM.getActiveBasketId();
	// EDGE-165017 Manuga
	intervalFunc = setInterval(addCustomButtonSC, 1000);
	//EDGE-165017 Manuga
	console.log("window.basketId", window.basketId);
	if (CS.SM.registerUIPlugin) {
		CS.SM.UIPlugin.alterAlertMessage = async function (message, type) {
			return { message, type };
		};
		CS.SM.UIPlugin.buttonClickHandler = async function (buttonSettings) {
            // DIGI-14126 : START
			if(window.OpportunityType.includes('CHOWN') && ( buttonSettings.id === "reserveNumber" )){
				if(window.basketType == 'Incoming'){
					await CS.SM.displayMessage('Plan / Add-on modifications are not allowed in CHOWN and should be performed through subsequent MACD Order');
				}else if(window.basketType == 'Outgoing'){
					await CS.SM.displayMessage('CHOWN transaction does not allow this operation in outgoing customer account');
				}
			}
			// DIGI-14126 : END
			//start
			console.log("buttonClickHandler: id=", buttonSettings.id, buttonSettings);
			var url = "";
			var redirectURI = "/apex/";
			if (communitySiteId) {
				redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
			}
			url = redirectURI;
			//Back to basket button handling
			if (buttonSettings.id === "backToBasketInternal") {
				//if button settings didnt provide basket id value, then fetch it from url
				if (buttonSettings.basketId === undefined || buttonSettings.basketId === null) {
					var basketIdstr = window.location.href.includes("basketId=") ? window.location.href.split("basketId=")[1] : window.location.href;
					window.basketId = basketIdstr.split("&")[0];
				} else {
					window.basketId = buttonSettings.basketId;
				}
				if (window.location.href.toLowerCase().includes("partner")) {
					var currentURL1 = "/s/sfdcpage/%2Fapex%2Fcsbb__BasketbuilderApp%3FId%3D";
					// window.location.href = currentURL;
					console.log("currUrl>>" + currentURL1);
					//url = decodeURI(currentURL + currentURL1 + window.basketId);
					url = decodeURI(currentURL1 + window.basketId);
					//workaround to fix back to basket issue in Communities
					//window.top.location.replace(url);
					url = "/" + window.basketId;
					//sforce.one.navigateToURL(url,true); // EDGE-155982 Gnana : using this as suggested by Salesforce
				} else {
					//window.siteId === null and if its not a parter url
					url = "/" + window.basketId;
				}
				return Promise.resolve(url);
			}
			let solution = await CS.SM.getActiveSolution();
			
			window.activeSolutionID = solution.solutionId; // set for EDGE-174219
			//DIGI-18801 : Added Button to get Remaining term and amount for CHOWN Incoming		
			if(buttonSettings.id === "GetTermandAmount") {
				console.log('demo');
				await RemainingAmount.GetTermandAmount();
			}
			//Pallavi Start DOP Changes
			if (solution.name === DOP_COMPONENT_NAMES.solution && (buttonSettings.id === "orderEnrichment" || buttonSettings.id === "getPriceScheduleAPI" || buttonSettings.id === "CheckOneFund" || buttonSettings.id === "checkInventory")) {
				console.log("buttonClickHandler: id=", buttonSettings.id, buttonSettings);
				var url = "";
				var redirectURI = "/apex/";
				if (window.communitySiteId) {
					redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				if (buttonSettings.id === "orderEnrichment") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						setTimeout(createOEUI, 200);
						return Promise.resolve("null");
					} else {
						CS.SM.displayMessage("Can not do order enrichment when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "CheckOneFund") {
					RedemptionUtilityCommon.checkOnefundBalance(); 
				} else if (buttonSettings.id === "checkInventory") {
					// EDGE-136691 - Fix to show check inventory button
					//Updated as part of EDGE-146972  Get the Device details for Stock Check before validate and Save as well,added query parameters solutionID,callerName
					//console.log('basketId', basketId);
					callerName_DOP = "Mobile Device";
					console.log('callerName_DOP&');
					// await CS.SM.getActiveSolution().then((product) => {
					let solution = CS.SM.getActiveSolution();
					solutionID = solution.solutionId;
					//   });
					if (window.communitySiteId) {
						//url = url + encodeURIComponent('c__StockCheckPage?basketID=' + basketId );
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = "c__StockCheckPage?basketId=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerName_DOP;
						} else {
							url = "/partners/";
							url = url + ("c__StockCheckPage?basketId=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerName_DOP);
						}
					} else {
						url = url + "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerName_DOP;
					}
					console.log("url: ", url);
					return Promise.resolve(url);
				}
				// Added as part of EDGE_140968 - Start
				else if (buttonSettings.id === "getPriceScheduleAPI") {
					//console.log('inside getPriceScheduleAPI button...');
					let solutionId = "";
					let discountStatus = "";
					let correlationId = "";
					var solName = "";
					IsDiscountCheckNeeded_DOP = false;
					IsRedeemFundCheckNeeded_DOP = false;
					callerName_DOP = "Mobile Device";
					solName = "Mobile Device";
					uniquehexDigitCode = Date.now();
					//await CS.SM.getActiveSolution().then((product) => {
					let product = await CS.SM.getActiveSolution();
					solution = product;
					solutionId = solution.solutionId;
					solutionID = solution.solutionId;
					//console.log('solution...' + solution.name);
					if (solution.name.includes(DOP_COMPONENT_NAMES.solution)) {
						if (solution.components && Object.values(solution.components).length > 0) {
							//console.log('solution.components...' + solution.components);
							if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
								//console.log('solution.schema.configurations...' + solution.schema.configurations);
								Object.values(solution.schema.configurations).forEach((config) => {
									/*var correlationIds = Object.values(config.attributes).filter(correlationId => {
										return correlationId.name === 'correlationId' && !correlationId.value
									});*/
									let correlationIds = config.getAttribute("correlationid");
									if (correlationIds && correlationIds != null && correlationIds && correlationIds.value) {
										//console.log('correlationId...' + correlationId);
										correlationId = correlationIds.value;
									}
									//console.log('###correlationId###' + correlationId);
									/*var discount_Status = Object.values(config.attributes).filter(discount_Status => {
										return discount_Status.name === 'DiscountStatus'
									});*/
									let discount_Status = config.getAttribute("DiscountStatus");
									if (discount_Status && discount_Status != null && discount_Status && discount_Status.value) {
										//console.log('discount_Status...' + discount_Status[0].value);
										discountStatus = discount_Status.value;
									}
									//console.log('###discountStatus###' + discountStatus);
								});
							}
							//Object.values(solution.components).forEach((comp) => {
							let comp = solution.getComponentByName(DOP_COMPONENT_NAMES.deviceOutRight);
							//if (comp.name === DOP_COMPONENT_NAMES.deviceOutRight) {
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								Object.values(comp.schema.configurations).forEach((config) => {
									/*var IsRedeemFundCheckNeededAtAtt = Object.values(config.attributes).filter(IsRedeemFundCheckNeededAt => {
										return IsRedeemFundCheckNeededAt.name === 'IsRedeemFundCheckNeeded'
									});*/
									let IsRedeemFundCheckNeededAtAtt = config.getAttribute("IsRedeemFundCheckNeeded");
									if (IsRedeemFundCheckNeededAtAtt.value === true && discountStatus !== "Locked") {
										//console.log('discountStatus locked');
										IsRedeemFundCheckNeeded_DOP = true;
									}
									//console.log('###IsDiscountCheckNeededAtt###' + IsRedeemFundCheckNeeded_DOP);
									if (IsRedeemFundCheckNeededAtAtt.value === true && discountStatus === "Locked" && correlationId === "") {
										IsRedeemFundCheckNeeded_DOP = true;
									}
								});
							}
							//}
							//});
						}
					}
					// });
					if (window.communitySiteId) {
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded_DOP +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded_DOP +
								"&callerName=" +
								callerName_DOP +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&i=";
						} else {
							url = "/partners/";
							url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded_DOP +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded_DOP +
								"&callerName=" +
								callerName_DOP +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&i=";
						}
					} else {
						//console.log('IsRedeemFundCheckNeeded_DOP == ', IsRedeemFundCheckNeeded_DOP);
						url =
							url +
							"c__GetPriceScheduleCommon?basketId=" +
							basketId +
							"&SolutionId=" +
							solutionId +
							"&accountId=" +
							accountId +
							"&discountStatus=" +
							discountStatus +
							"&correlationId=" +
							correlationId +
							"&IsDiscountCheckNeeded=" +
							IsDiscountCheckNeeded_DOP +
							"&IsRedeemFundCheckNeeded=" +
							IsRedeemFundCheckNeeded_DOP +
							"&callerName=" +
							callerName_DOP +
							"&solutionName=" +
							solName +
							"&basketNum=" +
							basketNum +
							"&hexid=" +
							uniquehexDigitCode;
					}
					pricingUtils.setDiscountAttribute();
					pricingUtils.customLockSolutionConsole("lock");
					console.log("url---->" + url);
					return Promise.resolve(url);
				}
				// Added as part of EDGE_140968 - End
			}
			//Pallavi End
			//Pallavi End
			// Arijay Start for Next Gen Mobility
			if (solution.name === NXTGENCON_COMPONENT_NAMES.nxtGenMainSol) {
				console.log("Inside Next Generation Mobility buttonClickHandler--->", buttonSettings.id, buttonSettings);
				// added by shubhi for edge EDGE-170016 start----------------
				if(window.basketRecordType==='Inflight Change' && (buttonSettings.id ==="numReserve" || buttonSettings.id ==="checkPortin" || buttonSettings.id ==="syncTransitionDevices_NGEM" || buttonSettings.id ==="ReactivateService")){					
					await CS.SM.displayMessage("Inflight amend does not allow this operation","error");
					return Promise.resolve(false);
				}// added by shubhi for edge EDGE-170016 end----------------
                //Edge-152456 strt
				if(window.OpportunityType.includes('CHOWN') && (buttonSettings.id ==="numReserve" || buttonSettings.id ==="checkPortin" || buttonSettings.id ==="syncTransitionDevices_NGEM" || buttonSettings.id ==="ReactivateService" || buttonSettings.id ==="checkInventory" || buttonSettings.id==="CheckOneFund" )){
					//EDGE-204313 start---
					if(window.basketType==='Incoming'){
						await CS.SM.displayMessage('Plan / Add-on modifications are not allowed and should be performed through subsequent MACD Order');
					}else if(window.basketType==='Outgoing'){
						await CS.SM.displayMessage('CHOWN transaction does not allow this operation in outgoing customer account');
					}
					//EDGE-204313 end----
					return Promise.resolve(false);
				}
                //Edge-152456end 
				
				// Added as a part of 150065
				let url = "";
				var redirectURI = "/apex/";
				if (window.communitySiteId) {
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/";
					else redirectURI = "/partners/";
				}
				url = redirectURI;
				if (buttonSettings.id === "checkInventory") {

					console.log("basketId", basketId);
					callerName_NG_Device = "Device";
                    
					//console.log('communitySiteId_NGEM', communitySiteId_NGEM);
					//await CS.SM.getActiveSolution().then((product) => {
					solutionID = solution.solutionId;
					//});
					if (window.communitySiteId) {
						//url = url + encodeURIComponent('c__StockCheckPage?basketID=' + basketId );
						var baseurl = window.location.href;
                        console.log('callerName_NG_Device****');
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = "c__StockCheckPage?basketId=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerName_NG_Device +"&solutionName=" +solution.name; /*DPG-3510, Ila: Added solutionName parameter*/
						} else {
							url = "/partners/";
							url = url + ("c__StockCheckPage?basketId=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerName_NG_Device +"&solutionName=" +solution.name); /*DPG-3510, Ila: Added solutionName parameter*/
						}
					} else {
						url = url + "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerName_NG_Device +"&solutionName=" +solution.name; /*DPG-3510, Ila: Added solutionName parameter*/
					}
					console.log("url: ", url);
					return Promise.resolve(url);
				}
				//EDGE-153402
				else if (buttonSettings.id === "numReserve") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						if (window.communitySiteId) {
							// Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
							//url = '/partners/';
							var baseurl = window.location.href;
							if (baseurl.includes("partners.enterprise.telstra.com.au")) {
								url = "c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name;
							} else {
								url = "/partners/";
								url = url + ("c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name);
							}
						} else {
							url = "/apex/c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name;
						}
						//EDGE-93081 - Kalashree, Conditionally render page - end
						return Promise.resolve(url);
						//return Promise.resolve('/apex/c__NumberReservationPage?basketId=' + basketId);
					} else {
						CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				}
				//EDGE-165570
				else if (buttonSettings.id === "checkPortin") {
					// EDGE-117585 - Show 'Port-in check' button
					if (window.communitySiteId) {
						//url = url + encodeURIComponent("c__PortInPage?basketID=" + basketId);
							/* As part of INC000094860789/EDGE-200605 Starts */
                            var baseurl = window.location.href;
                            if (baseurl.includes("partners.enterprise.telstra.com.au")) {
                                url = "c__PortInPage?basketID=" + basketId ;
                            } else {
                                url = "/partners/";
                                url = url + ("c__PortInPage?basketID=" + basketId );
                            }                        
                            /* As part of INC000094860789/EDGE-200605 Ends */
					} else {
						url = url + "c__PortInPage?basketID=" + basketId;
					}
					return Promise.resolve(url);
				}
				/////////////////////////////////////// EDGE-148662 start /////////////////////////////////////////////////
				else if (buttonSettings.id === "getPriceScheduleAPI" || buttonSettings.id === "getPriceScheduleAPI_NGdevice") {
					let discountStatus = "";
					let correlationId = "";
					var solName = "";
					IsDiscountCheckNeeded_ngdevice = false;
					IsRedeemFundCheckNeeded_ngdevice = false;
					callerName_NG_Device = "Device";
					solName = "Device";
					uniquehexDigitCode = Date.now();
					//await CS.SM.getActiveSolution().then((product) => {
					//var solution=product;
					solutionID = solution.solutionId;
					if (solution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
						if (solution.components && Object.values(solution.components).length > 0) {
							if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
								Object.values(solution.schema.configurations).forEach((config) => {
									/*var correlationIds = Object.values(config.attributes).filter(correlationId => {
                                        return correlationId.name === 'correlationId'
									});*/
									let correlationIds = config.getAttribute("correlationId");
									if (correlationIds && correlationIds != null && correlationIds && correlationIds.value) {
										correlationId = correlationIds.value;
									}
									/* var discount_Status = Object.values(config.attributes).filter(discount_Status => {
										 return discount_Status.name === 'DiscountStatus'
									 });*/
									let discount_Status = config.getAttribute("DiscountStatus");
									if (discount_Status && discount_Status != null && discount_Status && discount_Status.value) {
										discountStatus = discount_Status.value;
									}
								});
								//Object.values(solution.components).forEach((comp) => {
								let comp = solution.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.nextGenDevice);
								//if (comp.name === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) {
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									Object.values(comp.schema.configurations).forEach((config) => {
										/* var IsRedeemFundCheckNeeded_ngdeviceAttr = Object.values(config.attributes).filter(Attr => {
											 return Attr.name === 'IsRedeemFundCheckNeeded'
										 });*/
										let IsRedeemFundCheckNeeded_ngdeviceAttr = config.getAttribute("IsRedeemFundCheckNeeded");
										if (IsRedeemFundCheckNeeded_ngdeviceAttr.value === true) {
											IsRedeemFundCheckNeeded_ngdevice = true;
										}
										//Edge-149830 start
										if (config.relatedProductList && config.relatedProductList.length > 0) {
											for (var relatedProduct of config.relatedProductList) {
												/*var IsRedeemFundCheckNeeded_ngdeviceAttr = Object.values(relatedProduct.configuration.attributes).filter(Attr => {
													return Attr.name === 'IsRedeemFundCheckNeeded'
												});*/
												let IsRedeemFundCheckNeeded_ngdeviceAttr = config.getAttribute("IsRedeemFundCheckNeeded");
												if (IsRedeemFundCheckNeeded_ngdeviceAttr.value === true) {
													IsRedeemFundCheckNeeded_ngdevice = true;
												}
											}
										} //Edge-149830 end
									});
								}
								// }
								//  });
							}
						}
					}
					//});
					if (window.communitySiteId) {
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionID +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded_ngdevice +
								"&callerName=" +
								callerName_NG_Device +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded_ngdevice;
						} else {
							url = "/partners/";
							url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionID +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded_ngdevice +
								"&callerName=" +
								callerName_NG_Device +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded_ngdevice;
						}
					} else {
						url =
							url +
							"c__GetPriceScheduleCommon?basketId=" +
							basketId +
							"&SolutionId=" +
							solutionID +
							"&accountId=" +
							accountId +
							"&discountStatus=" +
							discountStatus +
							"&correlationId=" +
							correlationId +
							"&IsDiscountCheckNeeded=" +
							IsDiscountCheckNeeded_ngdevice +
							"&callerName=" +
							callerName_NG_Device +
							"&solutionName=" +
							solName +
							"&basketNum=" +
							basketNum +
							"&IsRedeemFundCheckNeeded=" +
							IsRedeemFundCheckNeeded_ngdevice;
					}
					pricingUtils.setDiscountAttribute();
					pricingUtils.customLockSolutionConsole("lock");
					console.log("url---->" + url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "CheckOneFund") {
					RedemptionUtilityCommon.checkOnefundBalance(); //Edge-149830
					return Promise.resolve(true);
				}
				//Added by Aman Soni for EDGE-173469 || Modified by Aman Soni for EDGE-191077, EDGE-191077 & EDGE-194029 || Start

				//Monali
				else if(buttonSettings.id === "syncTransitionDevices_NGEM" || buttonSettings.id === "syncTransitionAccessory_NGEM"){

					var offerId;
					var solutionId;
					var billingAccountNumber;
					let solutionAM = await CS.SM.getActiveSolution();
					if(solutionAM.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)){
						let solConfigs = solutionAM.getConfigurations();


						let compOutgoing = '';
						let contractType = '';
						for(var solConfig of Object.values(solConfigs)){
							if(solConfig.guid){
								if(solutionAM.components && Object.values(solutionAM.components).length > 0){

                                      
                                    if(buttonSettings.id === "syncTransitionDevices_NGEM" ){
                                       // compOutgoing = comp;
											contractType = 'MRO';
                                        compOutgoing=solutionAM.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
                                    }
                                    // Monali/Mahima- DPG-3889
                                    else if(buttonSettings.id === "syncTransitionAccessory_NGEM" ){
                                        contractType = 'ARO';
                                        compOutgoing=solutionAM.getComponentByName(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory);
                                    }
                                    
									/*Object.values(solutionAM.components).forEach((comp) => {                                        
										if(comp.name === NEXTGENMOB_COMPONENT_NAMES.transitionDevice){
											compOutgoing = comp;
											contractType = 'MRO';
                                        	//break;
										}
                                        //Monali
                                        else if(comp.name === NEXTGENMOB_COMPONENT_NAMES.transitionAccessory){
											compOutgoing = comp;
											contractType = 'ARO';
                                        	//break;
										}
									});*/

								}
								
								if(compOutgoing){
									var insLstForStatusUpd = [];
									var instanceIDString;
									var deviceInstIdNew = "";
									var legacyBAN = '';
									let configs = compOutgoing.getConfigurations();


									if(configs){
										Object.values(configs).forEach((config) => {
											if (config.guid) {
												deviceInstIdNew = config.getAttribute("DeviceInstanceId");
												legacyBAN = config.getAttribute("LegacyBillingAccount");
											}
											insLstForStatusUpd.push(deviceInstIdNew.displayValue);
										});
										instanceIDString = insLstForStatusUpd.toString();
									}
								}
								
								let compName = compOutgoing.name;
							    offerId = solConfig.getAttribute("OfferId");
								solutionId = solConfig.getAttribute("SolutionId");
							    billingAccountNumber = solConfig.getAttribute("BillingAccountLookup");
								if(offerId.value === NEXTGENMOB_COMPONENT_NAMES.deviceOffeId && compName != ''){
									var legBan = legacyBAN.displayValue;
									if(legBan === undefined){
										legBan = '';
									}
									let urlparams = "c__TransferHardwareRepaymentVF?basketid=" +basketId + "&offerId=" +offerId.value + "&billingAccountNumber=" +billingAccountNumber.displayValue + "&category=" +compName + "&contractType=" +contractType + "&legacyBAN=" +legBan + "&solutionId=" +solutionId.displayValue + "&instanceIDString=" +instanceIDString;
									let url = window.location.href; 
									let redirectURI = "/apex/";
									if(communitySiteId){
											if (url.includes("partners.enterprise.telstra.com.au")) 
												redirectURI = "/apex/";
											else 
												redirectURI = "/partners/apex/";
									}
									url = redirectURI +urlparams;
									return Promise.resolve(url);								
								}else if(offerId.value === NEXTGENMOB_COMPONENT_NAMES.planOfferId){
									CS.SM.displayMessage("Please sync Transition Devices through Adaptive Mobility Device Offer", "error");
									return Promise.resolve(false);
								}
							}
						}						
					}
				}
				//Added by Aman Soni for EDGE-173469 || Modified by Aman Soni for EDGE-191076, EDGE-191077 & EDGE-194029 || End

				//Added by Shubhi for EDGE-185011 || Start
				else if(buttonSettings.id === "ReactivateService"){
					let urlparams=await ReactivateServiceUtils.invokeReactivateService('AdaptiveMobility',NEXTGENMOB_COMPONENT_NAMES.nextGenPlan,NEXTGENMOB_COMPONENT_NAMES.solutionname);
					//url = url + urlparams;
                    			return Promise.resolve(urlparams); //EDGE-198439
                }									
				//Added by shubhi for EDGE-185011 || End

				/////////////////////////////////////// EDGE-148662 end /////////////////////////////////////////////////
			}
			// Arinjay End for Next Gen Mobility
			//Arinjay Start for CWP
			//Kalashree. EDGE-216668
			// if(solution.name==='Telstra Collaboration Tenancy'){   DIGI-5648
			if(solution.name=== NGUC_TENANCY_OFFER_NAME){
                // DIGI-14126 : START
			    if(window.OpportunityType.includes('CHOWN') && ( buttonSettings.id === "reserveNumber" )){
				    if(window.basketType == 'Incoming'){
					  await CS.SM.displayMessage('Plan / Add-on modifications are not allowed in CHOWN and should be performed through subsequent MACD Order');
				   }else if(window.basketType == 'Outgoing'){
					 await CS.SM.displayMessage('CHOWN transaction does not allow this operation in outgoing customer account');
				  }
			   }
			   // DIGI-14126 : END
				if(buttonSettings.id === "broadSoftTenancy" ){
                    console.log('In broadSoftTenancy');
                    						if (communitySiteId) {
							// Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
							//url = '/partners/';
							var baseurl = window.location.href;
							if (baseurl.includes("partners.enterprise.telstra.com.au")) {
								url = "c__BroadsoftTenancyPage?basketId=" + basketId + "&solutionname=" + solution.name;
							} else {
								url = "/partners/";
								url = url + ("c__BroadsoftTenancyPage?basketId=" + basketId + "&solutionname=" + solution.name);
							}
						} else {
							url = "/apex/c__BroadsoftTenancyPage?basketId=" + basketId + "&solutionname=" + solution.name;
						}
						//EDGE-93081 - Kalashree, Conditionally render page - end
						return Promise.resolve(url);
                }
			}
			if (solution.name === "Connected Workplace") {
				//console.log('buttonSettings', buttonSettings.id);
				var url = "";
				var redirectURI = "/apex/";
				if (communitySiteId) {
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				if (buttonSettings.id === "ScSelectSiteAddressBtn") {
					var arrStr = "";
					if (existingSiteIds && existingSiteIds.length > 0) {
						arrStr = existingSiteIds.map((e) => e.adborID).join();
					}
					// console.log('basketId', basketId);
					//console.log('existingSiteIds', arrStr);
					if (communitySiteId) {
						url = url + encodeURIComponent("c__SCAddressSearchPage?basketId=" + basketId + "&adborIds=" + arrStr + "&caller=" + solution.name);
					} else {
						url = url + "c__SCAddressSearchPage?basketId=" + basketId + "&adborIds=" + arrStr + "&caller=" + solution.name;
					}
					//console.log('url: ', url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "getPriceScheduleAPI") {
					//Added by Aman Soni as a part of Deal Management story
					//let product = solution;
					let solutionId = "";
					let discountStatus = "";
					let correlationId = "";
					IsDiscountCheckNeeded = false;
					callerNameCWP = "CWP";
					solutionId = "";
					uniquehexDigitCode = Date.now();
					//await CS.SM.(false, true, true).then( solId => console.log(solId));
					//GA Changes
					//await CS.SM.getActiveSolution().then((product) => {
					//console.log(solution);
					//console.log('Inside getPriceScheduleAPI');
					//console.log('Inside getPriceScheduleAPI :: product :: ' + solution);
					//console.log('Inside getPriceScheduleAPI :: product :: ' + solution.solutionId);
					//solution = product;
					solutionId = solution.solutionId;
					gSolutionID = solution.solutionId;
					//console.log(' gSolutionID ' + gSolutionID);
					//updated by shubhi for handling multiple clicks
					//if (solution.name.includes(solution.name)) {
					if (solution.components && Object.values(solution.components).length > 0) {
						if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
							Object.values(solution.schema.configurations).forEach((config) => {
								/*var correlationIds = Object.values(config.attributes).filter(correlationId => {
									return correlationId.name === 'correlationId' && !correlationId.value
								});*/
								let correlationIds = config.getAttribute("correlationId");
								if (correlationIds && correlationIds != null && correlationIds && correlationIds.value && correlationIds.value != null) {
									correlationId = correlationIds.value;
								}
								/*var discount_Status = Object.values(config.attributes).filter(discount_Status => {
									return discount_Status.name === 'DiscountStatus'
								});*/
								let discount_Status = config.getAttribute("discountStatus");
								if (discount_Status && discount_Status != null && discount_Status && discount_Status.value && correlationIds && correlationIds.length > 0 && correlationIds[0].value != null) {
									discountStatus = discount_Status.value;
								}
								//Laxmi EDGE-135885 - Added Solution nae so that it can be sent in URL
								let solutionName = config.getAttribute("Solution Name");
								/*solutionName = Object.values(config.attributes).filter(sol => {
									return sol.name === 'Solution Name'
								});*/
							});
						}
						// Object.values(solution.components).forEach((comp) => {
						let comp = solution.getComponentByName(COMPONENT_NAMES.mobileSubscription);
						// console.log('Line 2258 ' + ' comp ' + comp.name + ' sol name ' + COMPONENT_NAMES.solution);
						//if (comp.name.includes(COMPONENT_NAMES.mobileSubscription)) {
						//console.log('Line 2259 condition is true ');
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							Object.values(comp.schema.configurations).forEach((config) => {
								let IsDiscountCheckNeededAtt = config.getAttribute("IsDiscountCheckNeeded");
								/*var IsDiscountCheckNeededAtt =  Object.values(config.attributes).filter(IsDiscountCheckNeededAtt => {
									return IsDiscountCheckNeededAtt.name === 'IsDiscountCheckNeeded'
								});*/
								// EDGE-131531 - Added check that the change Type should not be Active/Cancel
								let changeType = config.getAttribute("ChangeType");
								/*var changeType = Object.values(config.attributes).filter(changeType => {
									return changeType.name === 'ChangeType'
								});*/
								var changeTypeVal = changeType.value;
								if (IsDiscountCheckNeededAtt.value === true && discountStatus !== "Locked" && changeTypeVal != "Active" && changeTypeVal != "Cancel") {
									IsDiscountCheckNeeded = true;
								}
								// EDGE-131531 - Added check that the change Type should not be Active/Cancel
								if (IsDiscountCheckNeededAtt.value === true && discountStatus === "Locked" && correlationId === "" && changeTypeVal != "Active" && changeTypeVal != "Cancel") {
									IsDiscountCheckNeeded = true;
								}
							});
						}
						//}
						//});
					}
					//}
					//});
					//console.log('solutionName***************' + solutionName[0].value);
					//updated by shubhi for handling multiple clicks
					// console.log('inside getpricescheduleApi' + '@@@ accid-->' + accountId + ' @@@basketid-->' + basketId + ' @@@solid-->' + solutionId + '@@@disStatus-' + discountStatus + '@@@corelId-' + correlationId + '@@@@IsDiscountCheckNeeded--' + IsDiscountCheckNeeded);
					if (communitySiteId) {
						//Rohit Prodcution Fix Changes
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url =
								"c__GetPriceScheduleCommon?basketId=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&basketNum=" +
								basketNum +
								"&solutionName=" +
								COMPONENT_NAMES.mobileSubscription +
								"&callerName=" +
								callerNameCWP +
								"&hexid=" +
								uniquehexDigitCode; // EDGE-135885 - added Basket Num and Solution Name in URL
						} else {
							url = "/partners/";
							url =
								url +
								"c__GetPriceScheduleCommon?basketId=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&basketNum=" +
								basketNum +
								"&solutionName=" +
								COMPONENT_NAMES.mobileSubscription +
								"&callerName=" +
								callerNameCWP +
								"&hexid=" +
								uniquehexDigitCode; // EDGE-135885 - added Basket Num and Solution Name in URL
						}
					} else {
						url =
							url +
							"c__GetPriceScheduleCommon?basketId=" +
							basketId +
							"&SolutionId=" +
							solutionId +
							"&accountId=" +
							accountId +
							"&discountStatus=" +
							discountStatus +
							"&correlationId=" +
							correlationId +
							"&IsDiscountCheckNeeded=" +
							IsDiscountCheckNeeded +
							"&basketNum=" +
							basketNum +
							"&solutionName=" +
							COMPONENT_NAMES.mobileSubscription +
							"&callerName=" +
							callerNameCWP +
							"&hexid=" +
							uniquehexDigitCode; // EDGE-135885 - added Basket Num and Solution Name in URL
					}
					var payload11 = {
						command: "childWindow",
						data: "childWindow",
						caller: "CWP"
					};
					sessionStorage.setItem("payload11", JSON.stringify(payload11));
					pricingUtils.setDiscountAttribute();
					pricingUtils.customLockSolutionConsole("lock");
					//await sleep(11000);
					//var vfRedirect ='<div><iframe name="myIframeName" frameborder="0" scrolling="yes" src="'+ url +'" style="" height="100px" width="120px"></iframe></div>';
					return Promise.resolve(url);
				} else if (buttonSettings.id === "ScReserveNumbersBtn") {
					//console.log('SiteId: ', buttonSettings.configurationGuid, 'BasketId: ', basketId);
					var id = existingSiteIds.filter((obj) => {
						return obj.guid === buttonSettings.configurationGuid;
					});
					//console.log('Config data: ', id);
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						if (id && id.length > 0 && id[0].configId && id[0].configId.length > 0) {
							if (communitySiteId) {
								url = url + encodeURIComponent("c__NumberManagement?basketId=" + basketId + "&configId=" + id[0].configId);
							} else {
								url = url + "c__NumberManagement?basketId=" + basketId + "&configId=" + id[0].configId;
							}
							//console.log('url: ', url);
							return Promise.resolve(url);
						} else {
							CS.SM.displayMessage("Can not reserve numbers, configuration is not saved!", "info");
						}
					} else {
						CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				}
				//Added as part of DPG-563 for adding new button for ISDN30 tactical transition
				else if (buttonSettings.id === "ScReserveISDNTransitionNumbersBtn") {
					// console.log('SiteId: ', buttonSettings.configurationGuid, 'BasketId: ', basketId);
					var id = existingSiteIds.filter((obj) => {
						return obj.guid === buttonSettings.configurationGuid;
					});
					//console.log('Config data: ', id);
					if (basketChangeType === "Change Solution") {
						if (Utils.isOrderEnrichmentAllowed()) {
							//basketStage ==='Contract Accepted'
							if (id && id.length > 0 && id[0].configId && id[0].configId.length > 0) {
								if (communitySiteId) {
									url = url + encodeURIComponent("c__NumberManagementTacticalTransition?basketId=" + basketId + "&configId=" + id[0].configId);
								} else {
									url = url + "c__NumberManagementTacticalTransition?basketId=" + basketId + "&configId=" + id[0].configId;
								}
								console.log("url: ", url);
								return Promise.resolve(url);
							} else {
								CS.SM.displayMessage("Can not reserve numbers, configuration is not saved!", "info");
							}
						} else {
							CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						}
					} else {
						CS.SM.displayMessage("ISDN 10/20/30 Tactical screen is not available on New Provide", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "ScModifySiteAddressBtn") {
					if (Utils.isCommNegotiationAllowed()) {
						//basketStage!=='Contract Accepted'
						var arrStr = "";
						if (existingSiteIds && existingSiteIds.length > 0) {
							arrStr = existingSiteIds.map((e) => e.adborID).join();
						}
						console.log("SiteId: ", buttonSettings.configurationGuid, "BasketId: ", basketId);
						console.log("existingSiteIds", arrStr);
						if (communitySiteId) {
							url = url + encodeURIComponent("c__SCAddressSearchPage?basketId=" + basketId + "&adborIds=" + arrStr + "&configId=" + buttonSettings.configurationGuid + "&caller=" + COMPONENT_NAMES.solution);
						} else {
							url = url + "c__SCAddressSearchPage?basketId=" + basketId + "&adborIds=" + arrStr + "&configId=" + buttonSettings.configurationGuid + "&caller=" + COMPONENT_NAMES.solution;
							return Promise.resolve(url);
						}
					} else {
						CS.SM.displayMessage("Can not change address when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "ScSelectCheckpointBtn") {
					let inputMap = {};
					inputMap["GetBasket"] = basketId;
					let currentBasket = await CS.SM.getActiveBasket();
					await currentBasket.performRemoteAction("CustomButtonComparison", inputMap).then((result) => {
						//  alert(JSON.stringify(result));
						isMobileExists = result["isMobileExists"];
					});
					if (communitySiteId) {
						url = url + encodeURIComponent("c__CheckPointPage?id=" + basketId + "&isdtp=vw&isMobilityProduct=" + isMobileExists);
					} else {
						url = url + "c__CheckPointPage?id=" + basketId + "&isdtp=vw&isMobilityProduct=" + isMobileExists;
					}
					console.log("BasketId: ", basketId);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "numReserve") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						if (communitySiteId) {
							url = "/partners/";
							url = url + ("c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name);
						} else {
							url = "/apex/c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name;
						}
						return Promise.resolve(url);
						//return Promise.resolve('/apex/c__NumberManagementMobilityBulk?basketId=' + basketId);
					} else {
						CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "orderEnrichment") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						setTimeout(createOEUI, 200, "Mobile Subscription", COMPONENT_NAMES.mobileSubscription);
						return Promise.resolve("null");
					} else {
						CS.SM.displayMessage("Can not do order enrichment when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "ScMACSQCheckBtn") {
					//console.log('BasketId in ScMACSQCheckBtn: ', basketId);
					if (basketChangeType === "Change Solution" && (basketStage === "Draft" || basketStage === "Commercial Configuration")) {
						var siteAdborId;
						var ipSiteConfigId;
						//GA Changes
						//await CS.SM.getActiveSolution().then((product) => {
						//let product = await CS.SM.getActiveSolution();
						// console.log('ScMACSQCheckBtn', solution);
						if (/*solution.type &&*/ solution.name.includes(COMPONENT_NAMES.solution)) {
							if (solution.components && Object.values(solution.components).length > 0) {
								// Object.values(solution.components).forEach((comp) => {
								// if (comp.name === COMPONENT_NAMES.ipSite) {
								let comp = solution.getComponentByName(COMPONENT_NAMES.ipSite);
								// console.log('IP Site when ScMACSQCheckBtn clicked', comp);
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									var ipSiteConfig = Object.values(comp.schema.configurations).find((config) => {
										//RF++
										return config.guid === buttonSettings.configurationGuid;
									});
									//console.log('ipSiteConfig', ipSiteConfig);
									if (ipSiteConfig && ipSiteConfig[0].attributes && Object.values(ipSiteConfig[0].attributes).length > 0) {
										if (ipSiteConfig[0].id && ipSiteConfig[0].replacedConfigId) {
											ipSiteConfigId = ipSiteConfig[0].id;
										}
										/*var adbordIdAttribute = Object.values(ipSiteConfig[0].attributes).filter(attr => {
											return attr.name === 'AdborID'
										});*/
										let adbordIdAttribute = ipSiteConfig[0].getAttribute("AdborID");
										//console.log('adbordIdAttribute', adbordIdAttribute);
										if (adbordIdAttribute) {
											siteAdborId = adbordIdAttribute.value;
										}
									}
								}
								//}
								// });
							}
						}
						//});
						console.log("Site AdborId in ScMACSQCheckBtn: ", siteAdborId);
						if (ipSiteConfigId) {
							if (communitySiteId) {
								url = url + encodeURIComponent("c__SCSQCheckPage?basketId=" + basketId + "&adborId=" + siteAdborId + "&configGUID=" + buttonSettings.configurationGuid);
							} else {
								url = url + "c__SCSQCheckPage?basketId=" + basketId + "&adborId=" + siteAdborId + "&configGUID=" + buttonSettings.configurationGuid;
							}
							return Promise.resolve(url);
						} else {
							CS.SM.displayMessage("Can not initiate SQ Check when IP Site is not added to MAC Basket", "info");
							return Promise.resolve(true);
						}
					} else {
						if (basketChangeType !== "Change Solution") {
							CS.SM.displayMessage("Can not initiate SQ Check for new baskets", "info");
						} else {
							CS.SM.displayMessage("Can not initiate SQ Check when basket is in " + basketStage + " stage", "info");
						}
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "checkInventory") {
					// EDGE-108289 - Fix to show check inventory button
					console.log("basketId", basketId);
					console.log("existingSiteIds", arrStr);
					callerNameCWP = "CWP";
					//Updated as part of EDGE-146972  Get the Device details for Stock Check before validate and Save as well,added query parameters solutionID,callerName
					//await CS.SM.getActiveSolution().then((product) => {
					gSolutionID = solution.solutionId;
					//});
					if (communitySiteId) {
                        console.log('callerNameCWP**');
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + gSolutionID + "&callerName=" + callerNameCWP;
						} else {
							url = "/partners/";
							url = url + "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + gSolutionID + "&callerName=" + callerNameCWP;
						}
						//url = url + encodeURIComponent('c__StockCheckPage?basketID=' + basketId+ '&solutionId=' + gSolutionID+'&callerName='+callerNameCWP );
					} else {
						url = url + "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + gSolutionID + "&callerName=" + callerNameCWP;
					}
					console.log("url: ", url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "checkPortin") {
					// EDGE-117585 - Show 'Port-in check' button
					if (communitySiteId) {
						//url = url + encodeURIComponent("c__PortInPage?basketID=" + basketId);
							/* As part of INC000094860789/EDGE-200605 Starts */
                            var baseurl = window.location.href;
                            if (baseurl.includes("partners.enterprise.telstra.com.au")) {
                                url = "c__PortInPage?basketID=" + basketId ;
                            } else {
                                url = "/partners/";
                                url = url + ("c__PortInPage?basketID=" + basketId );
                            }
                            /* As part of INC000094860789/EDGE-200605 Ends */
					} else {
						url = url + "c__PortInPage?basketID=" + basketId;
					}
					return Promise.resolve(url);
				}
				return Promise.resolve(true);
			}
			// Arinjay End for CWP
			// Arinjay Start for CMP
			//console.log('solution name ', solution.name);
			//console.log('buttonSettings ', buttonSettings);
			if (
				solution.name === ENTERPRISE_COMPONENTS.enterpriseMobility &&
				(buttonSettings.id === "BulkOrderEnrichment" ||
					buttonSettings.id === "msOrderEnrichment" ||
					buttonSettings.id === "numReserve" ||
					buttonSettings.id === "numberreservationnew" ||
					buttonSettings.id === "checkInventory" ||
					buttonSettings.id === "getPriceScheduleAPI" ||
					buttonSettings.id === "CheckOneFund" ||
					buttonSettings.id === "checkPortin" ||
					buttonSettings.id === "ReactivateService" )
			) {
				url = window.location.href;
				var redirectURI = "/apex/";
				if (communitySiteId) {
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				if (buttonSettings.id === "msOrderEnrichment") {
					setTimeout(createOEUI, 200, "Mobile Subscription", ENTERPRISE_COMPONENTS.mobileSubscription);
					return Promise.resolve("null");
				} //Added by Venkat for Number Reservation
				//Added by Shubhi as part of Bulk OE story - EDGE-137466 || start
				else if (buttonSettings.id === "BulkOrderEnrichment") {
					setTimeout(BulkcreateOELogic, 200, "Mobile Subscription", ENTERPRISE_COMPONENTS.mobileSubscription);
					return Promise.resolve("null");
				}
				//Added by Shubhi as part of Bulk OE story - EDGE-137466 || end
				else if (buttonSettings.id === "numReserve") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						if (communitySiteId) {
							// Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
							//url = '/partners/';
							var baseurl = window.location.href;
							if (baseurl.includes("partners.enterprise.telstra.com.au")) {
								url = "c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name;
							} else {
								url = "/partners/";
								url = url + ("c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name);
							}
						} else {
							url = "/apex/c__NumberReservationPage?basketId=" + basketId + "&solutionname=" + solution.name;
						}
						//EDGE-93081 - Kalashree, Conditionally render page - end
						return Promise.resolve(url);
						//return Promise.resolve('/apex/c__NumberReservationPage?basketId=' + basketId);
					} else {
						CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "numberreservationnew") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						if (communitySiteId) {
							// Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
							//url = '/partners/';
							var baseurl = window.location.href;
							if (baseurl.includes("partners.enterprise.telstra.com.au")) {
								url = "c__NumberReservation?basketId=" + basketId;
							} else {
								url = "/partners/";
								url = url + ("c__NumberReservation?basketId=" + basketId);
							}
						} else {
							url = "/apex/c__NumberReservation?basketId=" + basketId;
						}
						//EDGE-93081 - Kalashree, Conditionally render page - end
						return Promise.resolve(url);
						//return Promise.resolve('/apex/c__NumberReservationPage?basketId=' + basketId);
					} else {
						CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "checkInventory") {
					// EDGE-108289 - Fix to show check inventory button
					console.log('basketId^^^^', basketId);
					if (communitySiteId) {
						url = url + encodeURIComponent("c__StockCheckPage?basketID=" + basketId);
					} else {
						url = url + "c__StockCheckPage?basketID=" + basketId;
					}
					//console.log('url: ', url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "getPriceScheduleAPI") {
					//Added by Aman Soni as a part of Deal Management story
					let solutionId = "";
					let discountStatus = "";
					let correlationId = "";
					IsDiscountCheckNeeded_EM = false;
					IsRedeemFundCheckNeeded_EM = false;
					callerName_EM = "Enterprise Mobility";
					//await CS.SM.(false, true, true).then( solId => console.log(solId));
					//await CS.SM.getActiveSolution().then((product) => {
					// Spring 20
					//let solution = await CS.SM.getActiveSolution();
					//solution = product;
					solutionId = solution.solutionId;
					solutionID = solution.solutionId;
					//updated by shubhi for handling multiple clicks
					if (solution && solution.name == ENTERPRISE_COMPONENTS.enterpriseMobility) {
						if (solution.components && Object.values(solution.components).length > 0) {
							if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
								Object.values(solution.schema.configurations).forEach((config) => {
									/*var correlationIds = Object.values(config.attributes).filter(correlationId => {
                                        return correlationId.name === 'correlationId' && !correlationId.value
									});*/
									var correlationIds = config.getAttribute("correlationId");
									if (correlationIds && correlationIds != null && correlationIds && correlationIds.value && correlationIds.value != null) {
										correlationId = correlationIds.value;
									}
									var discount_Status = config.getAttribute("DiscountStatus");
									/*var discount_Status = Object.values(config.attributes).filter(discount_Status => {
                                        return discount_Status.name === 'DiscountStatus'
                                    });*/
									if (discount_Status && discount_Status != null && discount_Status && discount_Status.value && correlationIds && correlationIds.length > 0 && correlationIds.value != null) {
										discountStatus = discount_Status.value;
									}
									solutionName = config.getAttribute("Solution Name");
									//Laxmi EDGE-135885 - Added Solution nae so that it can be sent in URL
									/*solutionName = Object.values(config.attributes).filter(solutionName => {
                                        return solutionName.name === 'Solution Name'
									});*/
								});
							}
							//Object.values(solution.components).forEach((comp) => {
							//if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
							let comp = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								//console.log('comp.schema.configurations', comp.schema.configurations);
								Object.values(comp.schema.configurations).forEach((config) => {
									//console.log('comp.schema.configurations', config.attributes);
									/*var IsDiscountCheckNeededAtt = Object.values(config.attributes).filter(IsDiscountCheckNeededAtt => {
										return IsDiscountCheckNeededAtt.name === 'IsDiscountCheckNeeded'
									});*/
									var IsDiscountCheckNeededAtt = config.getAttribute("IsDiscountCheckNeeded");
									// EDGE-131531 - Added check that the change Type should not be Active/Cancel
									/*var  = Object.values(config.attributes).filter(changeType => {
										return changeType.name === 'ChangeType'
									});*/
									var changeType = config.getAttribute("ChangeType");
									var changeTypeVal = changeType.value;
									//EDGE-140967 Added check by Ankit || start
									var IsRedeemFundCheckNeededAttr = config.getAttribute("IsRedeemFundCheckNeeded");
									/*var IsRedeemFundCheckNeededAttr = Object.values(config.attributes).filter(IsRedeemFundCheckNeededAttr => {
										return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded'
									});*/
									if (IsRedeemFundCheckNeededAttr.value === true && changeTypeVal != "Active") {
										IsRedeemFundCheckNeeded_EM = true;
									}
									//EDGE-140967 Added check by Ankit || End
									if (IsDiscountCheckNeededAtt.value === true && discountStatus !== "Locked" && changeTypeVal != "Active" && changeTypeVal != "Cancel") {
										IsDiscountCheckNeeded_EM = true;
									}
									// EDGE-131531 - Added check that the change Type should not be Active/Cancel
									if (IsDiscountCheckNeededAtt.value === true && discountStatus === "Locked" /*&& correlationIdRes===''*/ && changeTypeVal != "Active" && changeTypeVal != "Cancel") {
										IsDiscountCheckNeeded_EM = true;
									}
								});
							}
							// }
							// });
						}
					}
					//});
					//console.log('solutionName***************' + solutionName[0].value);
					//updated by shubhi for handling multiple clicks
					//console.log('inside getpricescheduleApi' + '@@@ accid-->' + accountId + ' @@@basketid-->' + basketId + ' @@@solid-->' + solutionId + '@@@disStatus-' + discountStatus + '@@@corelId-' + correlationId + '@@@@IsDiscountCheckNeeded--' + IsDiscountCheckNeeded_EM);
					if (communitySiteId) {
						//Rohit Prodcution Fix Changes
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url =
								"c__GetPriceScheduleCommon?basketId=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded_EM +
								"&basketNum=" +
								basketNum +
								"&solutionName=" +
								ENTERPRISE_COMPONENTS.mobileSubscription +
								"&callerName=" +
								callerName_EM +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded_EM; // EDGE-135885 - added Basket Num and Solution Name in URL	//EDGE-140967 Added IsRedeemFundCheckNeeded_EM by Ankit
						} else {
							url = "/partners/";
							url =
								url +
								"c__GetPriceScheduleCommon?basketId=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded_EM +
								"&basketNum=" +
								basketNum +
								"&solutionName=" +
								ENTERPRISE_COMPONENTS.mobileSubscription +
								"&callerName=" +
								callerName_EM +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded_EM; // EDGE-135885 - added Basket Num and Solution Name in URL //EDGE-140967 Added IsRedeemFundCheckNeeded_EM by Ankit
						}
					} else {
						url =
							url +
							"c__GetPriceScheduleCommon?basketId=" +
							basketId +
							"&SolutionId=" +
							solutionId +
							"&accountId=" +
							accountId +
							"&discountStatus=" +
							discountStatus +
							"&correlationId=" +
							correlationId +
							"&IsDiscountCheckNeeded=" +
							IsDiscountCheckNeeded_EM +
							"&basketNum=" +
							basketNum +
							"&solutionName=" +
							ENTERPRISE_COMPONENTS.mobileSubscription +
							"&callerName=" +
							callerName_EM +
							"&IsRedeemFundCheckNeeded=" +
							IsRedeemFundCheckNeeded_EM; // EDGE-135885 - added Basket Num and Solution Name in URL //EDGE-140967 Added IsRedeemFundCheckNeeded_EM by Ankit
					}
					var payload11 = {
						command: "childWindow",
						data: "childWindow",
						caller: "Enterprise Mobility"
					};
					sessionStorage.setItem("payload11", JSON.stringify(payload11));
					pricingUtils.setDiscountAttribute();
					pricingUtils.customLockSolutionConsole("lock");
					//await sleep(11000);
					//var vfRedirect ='<div><iframe name="myIframeName" frameborder="0" scrolling="yes" src="'+ url +'" style="" height="100px" width="120px"></iframe></div>';
					return Promise.resolve(url);
				} else if (buttonSettings.id === "CheckOneFund" && basketChangeType === "Change Solution") {
					//Added by romil
					//console.log('buttonSettings.id', buttonSettings.id);
					RedemptionUtils.displayRemainingBalanceAmt();
				} else if (buttonSettings.id === "checkPortin") {
					// EDGE-117585 - Show 'Port-in check' button
					if (communitySiteId) {
						//url = url + encodeURIComponent("c__PortInPage?basketID=" + basketId);
							/* As part of INC000094860789/EDGE-200605 Starts */
                            var baseurl = window.location.href;
                            if (baseurl.includes("partners.enterprise.telstra.com.au")) {
                                url = "c__PortInPage?basketID=" + basketId ;
                            } else {
                                url = "/partners/";
                                url = url + ("c__PortInPage?basketID=" + basketId );
                            }
                            /* As part of INC000094860789/EDGE-200605 Ends */
					} else {
						url = url + "c__PortInPage?basketID=" + basketId;
					}
					return Promise.resolve(url);
				}
				//Added by Shubhi for EDGE-185011 || Start
				else if(buttonSettings.id === "ReactivateService"){
					let urlparams=await ReactivateServiceUtils.invokeReactivateService('CMP',ENTERPRISE_COMPONENTS.mobileSubscription,ENTERPRISE_COMPONENTS .enterpriseMobility);
					//url = url + urlparams;
                    			return Promise.resolve(urlparams);//EDGE-198439
                }
				//Added by Aman Soni for EDGE-185011 || End
				return Promise.resolve(true);
			}
			// Arinjay End for CMP
			// Sukul Start
			// IOT
			if (solution.name === IOTMobility_COMPONENTS.solution && (buttonSettings.id === "msViewRateCard" || buttonSettings.id === "msOrderEnrichment")) {
				// console.log('buttonSettings', buttonSettings.id);
				if (communitySiteId) {
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage";
					else redirectURI = "/partners/s/sfdcpage";
				}
				url = redirectURI;
				if (buttonSettings.id === "msViewRateCard") {
					urlWin = window.location.href;
					//console.log('communitySiteId:', communitySiteId);
					if (communitySiteId) {
						url = url + encodeURIComponent("resource/RateCard");
					} else {
						// console.log('urlWin:', urlWin);
						url = "/resource/RateCard";
						//console.log('url:', url);
					}
					return Promise.resolve(url);
				}
				//Adityen -  Bulk order enrichment
				else if (buttonSettings.id === "msOrderEnrichment") {
					if (Utils.isOrderEnrichmentAllowed()) {
						/*basketStage === 'Contract Accepted'*/
						setTimeout(createBulkOE, 200, "IoT Subscription", IOTMobility_COMPONENTS.IOTSubscription);
						return Promise.resolve("null");
					} else {
						CS.SM.displayMessage("Can not do order enrichment when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				}
			}
			// Sukul End
			//Sukul Start
			// TMDM
			if (solution.name === TENANCY_COMPONENT_NAMES.solution && (buttonSettings.id === "ViewPriceBreakdownButton" || buttonSettings.id === "SCAddLegacyTenancy"  || buttonSettings.id === "TMDMRateCard")) {
				var vfRedirect = "";
				var offerid = "";
				var vendor = "";
				url = window.location.href;
				if (communitySiteId) {
					url = window.location.href;
					//if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/"; //Replace /apex/(shresth)
					else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				//let solution = await CS.SM.getActiveSolution();
				//await CS.SM.getActiveSolution().then((solution) => {
				if (solution.componentType && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
					//if (solution.components && solution.components.length > 0) {
					if (solution.components && Object.values(solution.components).length > 0) {
						if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
							//solution.schema.configurations.forEach((config) => {
							Object.values(solution.schema.configurations).forEach((config) => {
								//if (config.attributes && config.attributes.length > 0){
								if (config.attributes && Object.values(config.attributes).length > 0) {
									//offerid = config.attributes.filter((attr) => {
									offerid = config.getAttribute("OfferId");
									vendor = config.getAttribute("Vendor");
									/*offerid = Object.values(config.attributes).filter((attr) => {
                                        return attr.name === 'OfferId'
                                    });
                                    //vendor = config.attributes.filter((attr) => {
                                    vendor = Object.values(config.attributes).filter((attr) => {
                                        return attr.name === 'Vendor'
                                    });*/
								}
							});
						}
					}
				}
					//Payal: Commented below if condition as ViewPriceBreakdownButton is not required any more
				/*if (buttonSettings.id === "ViewPriceBreakdownButton") {
					if (communitySiteId) {
						//Updated by shresth(DPG-2084)
						/*url = url + encodeURIComponent('c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value);
                        console.log('Url ---->', url);
						url = "/partners/apex/";
						url = url + "c__RateMatrixForIoT?offerid=" + offerid.value;

					} else {
						console.log("inside ViewPriceBreakdownButton");
						//Updated by shresth(DPG-2084)
						/*url = url + encodeURIComponent('c__RateMatrixForManagedServicesPage?offerid=' + offerid[0].value + '&vendor=' + vendor[0].value);
                        //url = url + 'c__RateMatrixForManagedServicesPage?featureLevel=' + 'Standard' + '&techSupport=' + 'Bus Hrs' + '&type=End User Support';
                        console.log('Url ---->', url);
						url = "c__RateMatrixForIoT?offerid=" + offerid.value; //Added By Shresth DPG - 2084
					}
					return Promise.resolve(url);
				} else */if (buttonSettings.id === "SCAddLegacyTenancy") {
					// alert('****Im Inside Button setting'+JSON.stringify(buttonSettings));
					var arrStr = "";
					//console.log('basketId', basketId);
					//console.log('existingSiteIds', arrStr);
					if (communitySiteId) {
						url = url + encodeURIComponent("c__SCAddLegacyTenancy?basketId=" + basketId + "&caller=MDMTenancy");
					} else {
						url = url + "c__SCAddLegacyTenancy?id=" + basketId + "&caller=MDMTenancy";
					}
					vfRedirect = url;
					return Promise.resolve(url);
				}
			}
			// Sukul End
			// Added as part of EDGE-154495 start- Telstra Internet Direct
			if (solution.name === TID_COMPONENT_NAMES.solution && (buttonSettings.id === "ScSelectSiteAddressBtnTID" || buttonSettings.id === "orderEnrichment")) {
				//console.log('buttonClickHandler: id=', buttonSettings.id, buttonSettings);
				var url = "";
				var redirectURI = "/apex/";
				//Added check below to address URL issue for PRM User
				if (tidCommunitySiteId) {
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				if (buttonSettings.id === "ScSelectSiteAddressBtnTID") {
					if (Utils.isCommNegotiationAllowed()) {
						var arrStr = "";
						if (TID_existingSiteIds && TID_existingSiteIds.length > 0) {
							arrStr = TID_existingSiteIds.map((e) => e.adborID).join();
						}
						var offerIdValue = getOfferIdValue(); //Pooja
						//console.log('basketId', basketId);
						//console.log('TID_existingSiteIds', arrStr);
						//console.log('offerIdValue', offerIdValue);
						if (tidCommunitySiteId) {
							url = url + encodeURIComponent("c__SCAddressSearchPage?basketId=" + basketId + "&adborIds=" + arrStr + "&caller=" + TID_COMPONENT_NAMES.solution + "&offerId=" + offerIdValue);
						} else {
							url = url + "c__SCAddressSearchPage?basketId=" + basketId + "&adborIds=" + arrStr + "&caller=" + TID_COMPONENT_NAMES.solution + "&offerId=" + offerIdValue;
						}
						//console.log('url: ', url);
						return Promise.resolve(url);
					} else {
						CS.SM.displayMessage("Can not add site when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "orderEnrichment") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						setTimeout(createOEUI, 200);
						return Promise.resolve("null");
					} else {
						CS.SM.displayMessage("Can not do order enrichment when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				}
			}
			// Added as part of EDGE-154495 end - Telstra Internet Direct
			//Pallavi Start TC changes
			if (
				solution.name === NEXTGENUC_COMPONENTS.solution &&
				(buttonSettings.id === "UCReserveNumbersBtn" ||
					buttonSettings.id === "checkInventory" ||
					buttonSettings.id === "reserveNumber" ||
					buttonSettings.id === "getPriceScheduleAPIAccessory" ||
					buttonSettings.id === "getPriceScheduleAPI" ||
					buttonSettings.id === "getPriceScheduleAPIVoice" ||
					buttonSettings.id === "numberreservationnew" ||
					buttonSettings.id === "CheckOneFund")
			) {
				console.log("buttonClickHandler: id=", buttonSettings.id, buttonSettings);
				let url = "";
				var redirectURI = "/apex/";
				if (window.communitySiteId) {
					//Fix for Number reservation url issue in Prod - Venkat 21-09-19
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/";
					else redirectURI = "/partners/";
				}
				url = redirectURI;
				if (buttonSettings.id === "UCReserveNumbersBtn") {
					console.log("SiteId: ", buttonSettings.configurationGuid, "BasketId: ", basketId);
					var ucConfigId;
					if (basketStage === "Contract Accepted") {
						//await CS.SM.getActiveSolution().then((currentSolution) => { PD
						let currentSolution = await CS.SM.getActiveSolution();
						if (currentSolution.componentType && currentSolution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
							//PD type updated to componentType
							if (currentSolution.components && Object.values(currentSolution.components).length > 0) {
								//currentSolution.components.forEach((comp) => {PD
								// for (const comp of Object.values(currentSolution.components)) {
								//if (comp.name === NEXTGENUC_COMPONENTS.UC) {
								let comp = currentSolution.getComponentByName(NEXTGENUC_COMPONENTS.UC);
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									var ucConfig = Object.values(comp.schema.configurations).find((config) => {
										//RF++
										return config.guid === buttonSettings.configurationGuid;
									});
									//var ucConfig = comp.schema.configurations.filter(config => {
									//	return config.guid === buttonSettings.configurationGuid
									//});	PD
									if (ucConfig && ucConfig[0] && ucConfig[0].id) {
										ucConfigId = ucConfig[0].id;
									}
								}
								// }
								// }
							}
						}
						//});PD
						//console.log('ucConfigId', ucConfigId);
						if (ucConfigId) {
							if (window.communitySiteId) {
								url = "/partners/";
								url = url + "c__NumberManagement?basketId=" + basketId + "&configId=" + ucConfigId;
							} else {
								url = url + "c__NumberManagement?basketId=" + basketId + "&configId=" + ucConfigId;
							}
							return Promise.resolve(url);
						} else {
							CS.SM.displayMessage("Can not reserve numbers, configuration is not saved!", "info");
							return Promise.resolve(true);
						}
					} else {
						CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				} else if (buttonSettings.id === "checkInventory") {
					// EDGE-108289 - Fix to show check inventory button
					//Updated as part of EDGE-146972  Get the Device details for Stock Check before validate and Save as well,added query paramers solutionID,callerName
					//console.log('basketId', basketId);
					callerNameNGUC = "Devices";
					// await CS.SM.getActiveSolution().then((product) => {PD
					let basket = await CS.SM.getActiveBasket(); //INC000093780730
					//let solution = basket.getActiveSolution();
					//solutionID = product.solutionId;
					let solution = await CS.SM.getActiveSolution(); ////INC000093780730
					solutionID = solution.solutionId; //INC000093780730
					// });PD
					if (window.communitySiteId) {
                        console.log('callerNameNGUC///');
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerNameNGUC;
						} else {
							url = "/partners/";
							url = url + "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerNameNGUC;
						}
					} else {
						url = url + "c__StockCheckPage?basketID=" + basketId + "&solutionId=" + solutionID + "&callerName=" + callerNameNGUC;
					}
					//End EDGE-146972
					// console.log('url: ', url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "getPriceScheduleAPIAccessory") {
					// added by Romil for Edge-144161
					let solutionId = "";
					let discountStatus = "";
					let correlationId = "";
					var solName = "";
					IsDiscountCheckNeeded = false;
					let IsRedeemFundCheckNeeded = false;
					callerNameNGUC = "Accessories";
					solName = "Accessory";
					uniquehexDigitCode = Date.now();
					//await CS.SM.getActiveSolution().then((product) => {PD
					let product = await CS.SM.getActiveSolution();
					solution = product;
					solutionId = product.solutionId;
					solutionID = product.solutionId;
					if (solution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
						if (solution.components && Object.values(solution.components).length > 0) {
							if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
								Object.values(solution.schema.configurations).forEach((config) => {
									//var correlationIds = config.attributes.filter(correlationId => {
									//	return correlationId.name === 'correlationId_Accessory' && !correlationId.value
									//});PD*
									var correlationIds = config.getAttribute("correlationId_Accessory");

									if (correlationIds && correlationIds != null && correlationIds && correlationIds.value) {
										correlationId = correlationIds.value;
									}
									var discount_Status = config.getAttribute("DiscountStatus_Accessory"); //PD
									/*var discount_Status = Object.values(config.attributes).filter(discount_Status => {
                                        return discount_Status.name === 'DiscountStatus_Accessory';
                                    });*/ if (
										discount_Status &&
										discount_Status != null &&
										discount_Status &&
										discount_Status.value
									) {
										discountStatus = discount_Status.value;
									}
									//console.log('###discountStatus###' + discountStatus);
								});
							}
							//solution.components.forEach((comp) => {PD
							// for (const comp of Object.values(solution.components)) {
							//if (comp.name === NEXTGENUC_COMPONENTS.AccessoryMTS) {
							let comp = solution.getComponentByName(NEXTGENUC_COMPONENTS.AccessoryMTS);
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								//comp.schema.configurations.forEach((config) => {PD
								for (const config of Object.values(comp.schema.configurations)) {
									//var IsRedeemFundCheckNeededAttr = config.attributes.filter(IsRedeemFundCheckNeededAttr => {
									//	return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded'
									//});PD
									/*var IsRedeemFundCheckNeededAttr = Object.values(config.attributes).filter(IsRedeemFundCheckNeededAttr => {
										return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded';
									});*/ //PD
									var IsRedeemFundCheckNeededAttr = config.getAttribute("IsRedeemFundCheckNeeded");
									if (IsRedeemFundCheckNeededAttr.value === true) {
										IsRedeemFundCheckNeeded = true;
									}
								}
							}
							// }
							// }
						}
					}
					//});PD
					if (window.communitySiteId) {
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&callerName=" +
								callerNameNGUC +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded +
								"&i=";
						} else {
							url = "/partners/";
							url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&callerName=" +
								callerNameNGUC +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded +
								"&i=";
						}
					} else {
						url =
							url +
							"c__GetPriceScheduleCommon?basketId=" +
							basketId +
							"&SolutionId=" +
							solutionId +
							"&accountId=" +
							accountId +
							"&discountStatus=" +
							discountStatus +
							"&correlationId=" +
							correlationId +
							"&IsDiscountCheckNeeded=" +
							IsDiscountCheckNeeded +
							"&callerName=" +
							callerNameNGUC +
							"&solutionName=" +
							solName +
							"&basketNum=" +
							basketNum +
							"&hexid=" +
							uniquehexDigitCode +
							"&IsRedeemFundCheckNeeded=" +
							IsRedeemFundCheckNeeded;
					}
					pricingUtils.setDiscountAttribute();
					pricingUtils.customLockSolutionConsole("lock");
					//let vfRedirect ='<div><iframe id="getPriceifrm" frameborder="0" scrolling="yes" style="" height="100px" width="120px" src="'+ url +'"></iframe></div>';
					// console.log('url---->' + url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "reserveNumber") {
					// EDGE-59982  - Fix to show Number reservation button
					console.log("basketId", basketId);
					if (window.communitySiteId) {
						// Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
						/*url = '/partners/';
						 url = url + ('c__NumberReservationPage?basketId=' + basketId);**/
						//product fix for PRM do not remove
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = "c__NumberReservationPage?basketId=" + basketId;
						} else {
							url = "/partners/";
							url = url + "c__NumberReservationPage?basketId=" + basketId;
						}
					} else {
						url = url + "c__NumberReservationPage?basketId=" + basketId;
					}
					//console.log('url: ', url);
					return Promise.resolve(url);
				}
				//Added by Aman Soni as a part of EDGE-133963 || Start
				else if (buttonSettings.id === "getPriceScheduleAPI") {
					// updated by shubhi Edge-143527
					let solutionId = "";
					let discountStatus = "";
					let correlationId = "";
					var solName = "";
					IsDiscountCheckNeeded = false;
					IsRedeemFundCheckNeeded = false;
					callerNameNGUC = "Devices";
					solName = "Unified Communication Device";
					uniquehexDigitCode = Date.now();
					///await CS.SM.saveSolution(true, true).then( solId => console.log(solId));
					//await CS.SM.getActiveSolution().then((product) => {PD
					let solution = await CS.SM.getActiveSolution();
					// solution = product;
					solutionId = solution.solutionId;
					solutionID = solution.solutionId;
					if (solution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
						if (solution.components && Object.values(solution.components).length > 0) {
							if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
								//solution.schema.configurations.forEach((config) => {	PD
								for (const config of Object.values(solution.schema.configurations)) {
									//var correlationIds = config.attributes.filter(correlationId => {
									//	return correlationId.name === 'correlationId' && !correlationId.value
									//});PD
									var correlationIds = config.getAttribute("correlationId");
									/*var correlationIds = Object.values(config.attributes).filter(correlationId => {
                                        return correlationId.name === 'correlationId' && !correlationId.value;
                                    });*/
									if (correlationIds && correlationIds != null && correlationIds && correlationIds.value) {
										correlationId = correlationIds.value;
									}
									//console.log('###correlationId###' + correlationId);
									//var discount_Status = config.attributes.filter(discount_Status => {
									//	return discount_Status.name === 'DiscountStatus'
									//});PD
									var discount_Status = config.getAttribute("DiscountStatus");
									/* var discount_Status = Object.values(config.attributes).filter(discount_Status => {
										 return discount_Status.name === 'DiscountStatus';
									 });*/
									if (discount_Status && discount_Status != null && discount_Status && discount_Status.value) {
										discountStatus = discount_Status.value;
									}
									//console.log('###discountStatus[0].value###'+discountStatus[0].value);
									//console.log('###discountStatus###' + discountStatus);
								}
							}
							//solution.components.forEach((comp) => {PD
							//for (const comp of Object.values(solution.components)) {
							// Aditya updated for Voice EDGE-121376
							// if (comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
							let comp = solution.getComponentByName(NEXTGENUC_COMPONENTS.DevicesMTS);

							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								//comp.schema.configurations.forEach((config) => {PD
								for (let config of Object.values(comp.schema.configurations)) {
									//var IsDiscountCheckNeededAtt = config.attributes.filter(IsDiscountCheckNeededAt => {
									//	return IsDiscountCheckNeededAt.name === 'IsDiscountCheckNeeded'
									//});PD
									var IsDiscountCheckNeededAtt = config.getAttribute("IsDiscountCheckNeeded");
									/*var IsDiscountCheckNeededAtt = Object.values(config.attributes).filter(IsDiscountCheckNeededAt => {
										return IsDiscountCheckNeededAt.name === 'IsDiscountCheckNeeded'
									});*/
									//added by Romil for EDGE- 144161
									//var IsRedeemFundCheckNeededAttr = config.attributes.filter(IsRedeemFundCheckNeededAttr => {
									//	return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded'
									//});PD
									var IsRedeemFundCheckNeededAttr = config.getAttribute("IsRedeemFundCheckNeeded");
									/*var IsRedeemFundCheckNeededAttr = Object.values(config.attributes).filter(IsRedeemFundCheckNeededAttr => {
										return IsRedeemFundCheckNeededAttr.name === 'IsRedeemFundCheckNeeded'
									});*/
									if (IsDiscountCheckNeededAtt.value === true && discountStatus !== "Locked") {
										IsDiscountCheckNeeded = true;
									}
									// console.log('###IsDiscountCheckNeededAtt###' + IsDiscountCheckNeeded);
									if (IsDiscountCheckNeededAtt.value === true && discountStatus === "Locked" && correlationId === "") {
										IsDiscountCheckNeeded = true;
									}
									//EDGE-144161 Added check by Romil
									if (IsRedeemFundCheckNeededAttr.value === true) {
										IsRedeemFundCheckNeeded = true;
									}
								}
							}
							// }
							//}
						}
					}
					if (window.communitySiteId) {
						//Rohit Prodcution Fix Changes
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&callerName=" +
								callerNameNGUC +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded +
								"&i=";
						} else {
							url = "/partners/";
							url =
								url +
								"c__GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&callerName=" +
								callerNameNGUC +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&IsRedeemFundCheckNeeded=" +
								IsRedeemFundCheckNeeded +
								"&i=";
						}
					} else {
						url =
							url +
							"c__GetPriceScheduleCommon?basketId=" +
							basketId +
							"&SolutionId=" +
							solutionId +
							"&accountId=" +
							accountId +
							"&discountStatus=" +
							discountStatus +
							"&correlationId=" +
							correlationId +
							"&IsDiscountCheckNeeded=" +
							IsDiscountCheckNeeded +
							"&callerName=" +
							callerNameNGUC +
							"&solutionName=" +
							solName +
							"&basketNum=" +
							basketNum +
							"&hexid=" +
							uniquehexDigitCode +
							"&IsRedeemFundCheckNeeded=" +
							IsRedeemFundCheckNeeded;
					}
					//let payload11 ={
					//	command: 'childWindow',
					//	data: 'childWindow',
					//	caller: callerNameNGUC
					//};
					//sessionStorage.setItem("payload11", JSON.stringify(payload11));
					pricingUtils.setDiscountAttribute();
					pricingUtils.customLockSolutionConsole("lock");
					//let vfRedirect ='<div><iframe id="getPriceifrm" frameborder="0" scrolling="yes" style="" height="100px" width="120px" src="'+ url +'"></iframe></div>';
					//console.log('url---->' + url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "getPriceScheduleAPIVoice") {
					//Added by Aman Soni as a part of Deal Management story
					let solutionId = "";
					let discountStatus = "";
					let correlationId = "";
					callerNameNGUC = "Business Calling";
					let solName = "Business Calling";
					IsDiscountCheckNeeded = false;
					uniquehexDigitCode = Date.now();
					//await CS.SM.getActiveSolution().then((product) => {PD
					let product = await CS.SM.getActiveSolution();
					solution = product;
					solutionId = product.solutionId;
					solutionID = solutionId;
					if (solution.name.includes(NEXTGENUC_COMPONENTS.solution)) {
						if (solution.components && Object.values(solution.components).length > 0) {
							if (solution.schema && solution.schema.configurations && Object.values(solution.schema.configurations).length > 0) {
								//solution.schema.configurations.forEach((config) => {
								Object.values(solution.schema.configurations).forEach((config) => {
									var correlationIds = config.getAttribute("correlationId_voice");
									/*var correlationIds = Object.values(config.attributes).filter(correlationId => {
                                        return correlationId.name === 'correlationId_voice' && !correlationId.value
                                    });*/
									if (correlationIds && correlationIds != null && correlationIds && correlationIds.value) {
										correlationId = correlationIds.value;
									}
									//console.log('###correlationId###' + correlationId);
									var discount_Status = config.getAttribute("DiscountStatus_voice");
									/*var discount_Status = Object.values(config.attributes).filter(discount_Status => {
                                        return discount_Status.name === 'DiscountStatus_voice'
                                    });*/
									if (discount_Status && discount_Status != null && discount_Status && discount_Status.value) {
										discountStatus = discount_Status.value;
									}
									//console.log('###discountStatus[0].value###'+discountStatus[0].value);
									//console.log('###discountStatus###' + discountStatus);
								});
							}
							//solution.components.forEach((comp) => {PD
							//Object.values(solution.components).forEach((comp) => {
							// Aditya updated for Voice EDGE-121376
							//if (comp.name === NEXTGENUC_COMPONENTS.UC) {
							let comp = solution.getComponentByName(NEXTGENUC_COMPONENTS.UC);
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
								Object.values(comp.schema.configurations).forEach((config) => {
									let IsDiscountCheckNeededAtt = config.getAttribute("IsDiscountCheckNeeded");
									/*var IsDiscountCheckNeededAtt = Object.values(config.attributes).filter(IsDiscountCheckNeededAt => {
										return IsDiscountCheckNeededAt.name === 'IsDiscountCheckNeeded'
									});*/
									if (IsDiscountCheckNeededAtt.value === true && discountStatus !== "Locked") {
										IsDiscountCheckNeeded = true;
									}
									//console.log('###IsDiscountCheckNeededAtt###' + IsDiscountCheckNeeded);
									if (IsDiscountCheckNeededAtt.value === true && discountStatus === "Locked" && correlationId === "") {
										IsDiscountCheckNeeded = true;
									}
								});
							}
							// }
							// });
						}
					}
					//});PD
					if (window.communitySiteId) {
						//Rohit Prodcution Fix Changes
						var baseurl = window.location.href;
						if (baseurl.includes("partners.enterprise.telstra.com.au")) {
							url = url =
								url +
								"GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&callerName=" +
								callerNameNGUC +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&i=";
						} else {
							url = "/partners/";
							url =
								url +
								"GetPriceScheduleCommon?basketid=" +
								basketId +
								"&SolutionId=" +
								solutionId +
								"&accountId=" +
								accountId +
								"&discountStatus=" +
								discountStatus +
								"&correlationId=" +
								correlationId +
								"&IsDiscountCheckNeeded=" +
								IsDiscountCheckNeeded +
								"&callerName=" +
								callerNameNGUC +
								"&solutionName=" +
								solName +
								"&basketNum=" +
								basketNum +
								"&hexid=" +
								uniquehexDigitCode +
								"&i=";
						}
					} else {
						url =
							url +
							"c__GetPriceScheduleCommon?basketid=" +
							basketId +
							"&SolutionId=" +
							solutionId +
							"&accountId=" +
							accountId +
							"&discountStatus=" +
							discountStatus +
							"&correlationId=" +
							correlationId +
							"&IsDiscountCheckNeeded=" +
							IsDiscountCheckNeeded +
							"&callerName=" +
							callerNameNGUC +
							"&solutionName=" +
							solName +
							"&basketNum=" +
							basketNum +
							"&hexid=" +
							uniquehexDigitCode +
							"&i=";
						// EDGE-135885 - added Basket Num and Solution Name in URL
					}
					//let payload11 ={
					//	command: 'childWindow',
					//	data: 'childWindow',
					//	caller: callerNameNGUC
					//};
					//sessionStorage.setItem("payload11", JSON.stringify(payload11));
					pricingUtils.setDiscountAttribute();
					pricingUtils.customLockSolutionConsole("lock");
					//let vfRedirect1 ='<div><iframe id="getPriceifrm" frameborder="0" scrolling="yes" style="" height="100px" width="120px" src="'+ url +'"></iframe></div>';
					console.log("url---->" + url);
					return Promise.resolve(url);
				} else if (buttonSettings.id === "numberreservationnew") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						if (window.communitySiteId) {
							// Dheeraj Bhatt-EDGE-100662- UI Enhancements Fixed Number Search with Validations for Telstra Collaboration in both New and Modify Order Flow
							//url = '/partners/';
							var baseurl = window.location.href;
							if (baseurl.includes("partners.enterprise.telstra.com.au")) {
								url = "c__NumberReservation?basketId=" + basketId;
							} else {
								url = "/partners/";
								url = url + ("c__NumberReservation?basketId=" + basketId);
							}
						} else {
							url = "/apex/c__NumberReservation?basketId=" + basketId;
						}
						//EDGE-93081 - Kalashree, Conditionally render page - end
						return Promise.resolve(url);
						//return Promise.resolve('/apex/c__NumberReservationPage?basketId=' + basketId);
					} else {
						CS.SM.displayMessage("Can not do number reservation when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				}
				//Added by Aman Soni as a part of EDGE-133963 || End
				else if (buttonSettings.id === "CheckOneFund") {
					//Added by romil EDGE-130075,EDGE-136954
					//console.log('buttonSettings.id', buttonSettings.id);
					RedemptionUtilityCommon.checkOnefundBalance();
				}
				return Promise.resolve(true);
			}
			//Pallavi End
			//Pooja summer 20 changes starts here
			if (solution.name === EMS_COMPONENT_NAMES.solution && (buttonSettings.id === "orderEnrichment" || buttonSettings.id === "TenancyButton")) {
				//console.log('EMS buttonClickHandler: id=', buttonSettings.id, buttonSettings);
				var url = "";
				var redirectURI = "/apex/";
				//Added check below to address URL issue for PRM User
				if (CommunitySiteId) {
					url = window.location.href;
					//if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/"; //Replace /apex/(shresth)
					else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				if (buttonSettings.id === "orderEnrichment") {
					if (Utils.isOrderEnrichmentAllowed()) {
						//basketStage ==='Contract Accepted'
						setTimeout(createOEUI, 200);
						return Promise.resolve("null");
					} else {
						CS.SM.displayMessage("Can not do order enrichment when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				}
				if (buttonSettings.id === "TenancyButton") {
					if (Utils.isCommNegotiationAllowed()) {
						// Dont allow to open the Tenancy Page when the Basket stage is not commercial config
						//var accountId = '';
						var optyId = "";
						//console.log('basketId', basketId);
						//console.log('accountId', accountId);
						var tenancyTypeProdIdList = ["DMCAT_ProductSpecification_000537"];
						if (communitySiteId) {
							url = url + encodeURIComponent("c__existingTenancy?basketId=" + basketId + "&accountId=" + accountId + "&filterByTenancyType=" + "true" + "&tenancyTypeProdIdList=" + tenancyTypeProdIdList + "?isdtp=mn");
						} else {
							url = url + "c__existingTenancy?basketId=" + basketId + "&accountId=" + accountId + "&filterByTenancyType=" + "true" + "&tenancyTypeProdIdList=" + tenancyTypeProdIdList;
						}
						//console.log('url: ', url);
						return Promise.resolve(url);
					} else {
						CS.SM.displayMessage("Can not Save Tenancies when basket is in " + basketStage + " stage", "info");
						return Promise.resolve(true);
					}
				}
			}
			//Pooja summer 20 changes ends here
			//vivek : edge:206232 : START
						if (solution.name === NEXTGENUC_COMPONENTS.solution &&  buttonSettings.id === "TenancyButton") {
							if ( basketStage == 'Contract Accepted' && basketChangeType == "Change Solution" ) {
								
								var url = "";
								var redirectURI = "/apex/";
								if (window.communitySiteId) {
									url = window.location.href;
									//if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
									if (url.includes("partners.enterprise.telstra.com.au")) {
										redirectURI = "/apex/"; //Replace /apex/(shresth)
									}
									else{
										redirectURI = "/partners/";
									}
										
								}
									url = redirectURI;
								
									var tenancyTypeProdIdList = ["DMCAT_ProductSpecification_000311"];
									if (window.communitySiteId) {
										url = url + ("c__existingTenancy?basketId=" + basketId + "&accountId=" + accountId + "&filterByTenancyType=" + "true" + "&tenancyTypeProdIdList=" + tenancyTypeProdIdList +"&isTenancySelectionAfterApproval=" + "true");
									} else {
										url = url + "c__existingTenancy?basketId=" + basketId + "&accountId=" + accountId + "&filterByTenancyType=" + "true" + "&tenancyTypeProdIdList=" + tenancyTypeProdIdList + "&isTenancySelectionAfterApproval=" + "true";
									}
									return Promise.resolve(url);
								} else {
									CS.SM.displayMessage(" You can select tenancy only for Changed Solution when basket stage is Contract Accepted.", "info");
									return Promise.resolve(true);
								}
							
						}
					//vivek : edge:206232 : END
					//Vasu : START
			if (buttonSettings.id === "orderEnrichmentButton") {
				if ( basketStage == 'Contract Accepted') {
					let solutionId = "";
					let product = await CS.SM.getActiveSolution();
					solution = product;
					solutionId = product.solutionId;
					if(product.name=='Adaptive Mobility'){
						await window.afterOETabLoaded('', '', 'Enterprise Mobility', "");
					}else if(product.Name=='Corporate Mobile Plus'){
						await window.afterOETabLoaded('', '', 'Mobile Subscription', "");	
					}
					var url = "";
					var redirectURI = "/apex/";
					if (window.communitySiteId) {
						url = window.location.href;
						//if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
						if (url.includes("partners.enterprise.telstra.com.au")) {
							redirectURI = "/apex/"; //Replace /apex/(shresth)
						}
						else{
							redirectURI = "/partners/";
						}
							
					}
						url = redirectURI;
						if (window.communitySiteId) {
							url = url + ("c__OrderEnrichmentPage?solutionId=" + solutionId + "&basketId=" + basketId);
						} else {
							url = url + "c__OrderEnrichmentPage?solutionId=" + solutionId + "&basketId=" + basketId;
						}
						return Promise.resolve(url);
				} else {
					CS.SM.displayMessage(" Order Enrichment allowed when basket stage is Contract Accepted.", "info");
					return Promise.resolve(true);
				}
				
			}
			//Vasu : END
			return Promise.resolve(true);
		};
		//Pooja summer 20 changes starts here
		/*** updated for edge-117563 ***/
		//EMSPlugin_onCustomAttributeEdit = async function (componentName, configurationGuid, attributeName) {
		//CS.SM.UIPlugin.onCustomAttributeEdit = async function (componentName, configurationGuid, attributeName) {//Pooja
		CS.SM.UIPlugin.onCustomAttributeEdit = async function (solutionName, componentName, configurationGuid, attributeName) {
			
			//SDWAN rate card start DPG-3110
			if( solutionName == SDWAN_COMPONENTS.solution){
				console.log('sdwan==>');
				let url = "";
				let vfRedirect = "";
				let planId = "";
				let solution = await CS.SM.getActiveSolution();
				
				console.log('solution==>', solution);
				
				if (solution.componentType && solution.name.includes(SDWAN_COMPONENTS.solution)) {
					
					console.log('step 2', solution.getConfiguration(configurationGuid).getAttribute('plan name'));
					let SDWAN_ADAPTS1 = solution.getConfiguration(configurationGuid);
					
					if(SDWAN_ADAPTS1.attributes){
						
						let planDetail = solution.getConfiguration(configurationGuid).getAttribute('plan name');
						
						if(planDetail){
							planId = planDetail.value;
						}
					}
				}
					
				if (attributeName === "SDWANRateCardButton") {
					
						url = url + "c__RateMatrixForSDWAN?planId=" + planId;
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="300px" width="1000px"></iframe></div>';
						//console.log('Url ---->', url);
					
				}
				
				return Promise.resolve(vfRedirect);
			} 
			//SDWAN rate 
			
			//Pooja
			if (solutionName == NEXTGENUC_COMPONENTS.solution) {
				// console.log('Inside customAttributeEdit Guid--->' + configurationGuid + '@@@@@' + componentName);
				var url = "";
				var vfRedirect = "";
				var sol;
				var solutionId = "";
				var solutionName = "";
				let inputMap = {};
				var solution = window.currentSolutionName;
				var priceItemId = "";
				configId = configurationGuid;
				var BussinessId_Device = "";
				var CallingPlan = "";
				var offerid = "";
				var guid = "";
				var changeType = "";
				var Mode = ""; //Edge-120919
				//await CS.SM.getActiveSolution().then((product) => {// EDGE-154465
				let product = await CS.SM.getActiveSolution();
				sol = product;
				solutionId = product.solutionId; // EDGE-154465
				solutionName = product.solutionName; // EDGE-154465
				//if (sol.components && Object.values(sol.components).length > 0) {// EDGE-154465
				//sol.components.forEach((comp) => {// EDGE-154465
				//Object.values(sol.components).forEach((comp) => {
				/*if (comp.name === NEXTGENUC_COMPONENTS.DevicesMTS) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {// EDGE-154465
						//comp.schema.configurations.forEach((config) => {// EDGE-154465
						//Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
						//if (config.guid === configurationGuid) {
						let config = comp.getConfiguration(configurationGuid);
						if (config.attributes && Object.values(config.attributes).length > 0) {// EDGE-154465
							// EDGE-154465 start
							/*priceItemId = config.attributes.filter(a => {
								return a.name === 'ContractType'
							});
							BussinessId_Device = config.attributes.filter(a => {
								return a.name === 'BussinessId_Device'
							});PD
							let priceItemId = config.getAttribute('ContractType');
							/*priceItemId = Object.values(config.attributes).filter(a => {
								return a.name === 'ContractType'
							});
							let BussinessId_Device = config.getAttribute('BussinessId_Device')
							/*BussinessId_Device = Object.values(config.attributes).filter(a => {
								return a.name === 'BussinessId_Device'
							});
							// EDGE-154465 start
						}
						//}
						//});
					}
				}*/
				let comp = sol.getComponentByName(NEXTGENUC_COMPONENTS.UC);
				//if (comp.name === NEXTGENUC_COMPONENTS.UC) {
				if (comp) {
					//comp.schema.configurations.forEach((config) => {// EDGE-154465
					//Object.values(comp.schema.configurations).forEach((config) => {// EDGE-154465
					let config = comp.getConfiguration(configurationGuid);
					// if (config.guid === configurationGuid) {
					if (config) {
						// EDGE-154465
						// EDGE-154465 start
						/*var CallingPlans = config.attributes.filter(a => {
							return a.name === 'callingPlans'
						});PD*/
						//Gokul : Added jsonsio variable as a part of Edge-185639
						var Jsonsio;
						var jsonsios = config.getAttribute("json_sios");
						if (jsonsios) {
							Jsonsio = jsonsios.value; //EDGE-205510 : changes from displayValue to value
						}
						var CallingPlans = config.getAttribute("callingPlans");
						/*var CallingPlans = Object.values(config.attributes).filter(a => {
							return a.name === 'callingPlans'
						});*/
						if (CallingPlans) {
							CallingPlan = CallingPlans.displayValue;
						}
						/*var Modes = config.attributes.filter(a => {
							return a.name === 'Mode'
						});PD*/
						// EDGE-154465 end
						var Modes = config.getAttribute("Mode");
						/*var Modes = Object.values(config.attributes).filter(a => {
							return a.name === 'Mode'
						});*/
						if (Modes) {
							Mode = Modes.displayValue;
						}
						// EDGE-154465 start
						/*var offerids = config.attributes.filter(a => {
							return a.name === 'OfferId'
						});PD*/
						var offerids = config.getAttribute("OfferId");
						/*var offerids = Object.values(config.attributes).filter(a => {
							return a.name === 'OfferId'
						});*/
						// EDGE-154465 start
						if (offerids) {
							offerid = offerids.value;
						}
						//// EDGE-140157 start shubhi
						guid = config.guid;
						// EDGE-154465 start
						/*var ChangeTypes = config.attributes.filter(a => {
							return a.name === 'ChangeType'
						});*/
						var ChangeTypes = config.getAttribute("ChangeType");
						/*var ChangeTypes = Object.values(config.attributes).filter(a => {
							return a.name === 'ChangeType'
						});*/
						// EDGE-154465 end
						if (ChangeTypes) {
							changeType = ChangeTypes.value;
						}
						//// EDGE-140157 end shubhi
					}
					// }
					// });
				}
				//}
				//});
				//}
				//});
				//console.log("priceItemId-->" + priceItemId);
				//console.log("@@offerid@@" + offerid + " @@CallingPlan@@" + CallingPlan);
				//console.log("@@guid@@" + guid + " @@changeType@@" + changeType);
				var redirectURI = "/apex/";
				if (window.communitySiteId) {
					url = window.location.href;
					//if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/";
					//else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
                    else redirectURI = "/partners/";
				}
				url = redirectURI;
				console.log("@@@@attributeName--->" + attributeName);
				//Added for Promotions and discounts
				if (attributeName === "viewDiscounts") {
					//await CS.SM.saveSolution(true, true).then( solId => console.log(solId));
					pricingUtils.checkDiscountValidation(sol, "IsDiscountCheckNeeded", NEXTGENUC_COMPONENTS.DevicesMTS);
					if (window.communitySiteId) {
						url = "/partners/";
						url = url + "c__HandlingDiscounts?basketId=" + basketId + "&accountId=" + accountId + "&solutionId=" + solutionId + "&accessMode=ReadOnly" + "&customAttribute=" + attributeName + "&priceItemId=" + priceItemId + "&configId=" + configId + "&solutionName=Unified Communication Device";
						vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
						console.log("Url ---->", url);
					} else {
						url = url + "c__HandlingDiscounts?basketId=" + basketId + "&accountId=" + accountId + "&solutionId=" + solutionId + "&accessMode=ReadOnly" + "&customAttribute=" + attributeName + "&priceItemId=" + priceItemId + "&configId=" + configId + "&solutionName=Unified Communication Device";
						vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						console.log("Url ---->", url);
					}
					//console.log("vfRedirect--->" + vfRedirect);
				}
				//Added for Price Schedule
				if (attributeName === "Price Schedule") {
					if (window.communitySiteId) {
						url = "/partners/";
						url = url + "c__PriceSchedulePage?configId=" + configId + "&BussinessId_Device=" + BussinessId_Device[0].value + "&solutionName=Unified Communication Device" + "&contractType=" + priceItemId[0].displayValue;
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
						console.log("Url ---->", url);
					} else {
						url = url + "c__PriceSchedulePage?configId=" + configId + "&BussinessId_Device=" + BussinessId_Device[0].value + "&solutionName=Unified Communication Device" + "&contractType=" + priceItemId[0].displayValue;
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						console.log("Url ---->", url);
					}
					//console.log("vfRedirect--->" + vfRedirect);
				}
				// edge-
				//Added for Promotions and discounts
				if (attributeName === "NGUCRateCardButton") {
					let currentBasket = await CS.SM.getActiveBasket();
					if (window.communitySiteId) {
						//url = "/partners/";
						//updated url for EDGE-140157
						/*Updated URL to pass JSONSIO :Edge-185639*/
						url = url + "c__RateDiscountCardNGUC?CallingPlan=" + CallingPlan + "&solutionId=" + solutionId + "&offerid=" + offerid + "&guid=" + guid + "&changeType=" + changeType + "&Mode=" + Mode + "&Jsonsio=" + Jsonsio+"&compName="+componentName+"&basketStage="+currentBasket.basketStageValue; //Edge-120919
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="950px"></iframe></div>';
						//console.log("Url ---->", url);
					} else {
						//updated url for EDGE-140157
						/*Updated URL to pass JSONSIO :Edge-185639*/
						url = url + "c__RateDiscountCardNGUC?CallingPlan=" + CallingPlan + "&solutionId=" + solutionId + "&offerid=" + offerid + "&guid=" + guid + "&changeType=" + changeType + "&Mode=" + Mode + "&Jsonsio=" + Jsonsio+"&compName="+componentName+"&basketStage="+currentBasket.basketStageValue; //Edge-120919
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="460px" width="860px"></iframe></div>';
						//console.log("Url ---->", url);
					}
					//console.log("vfRedirect--->" + vfRedirect);
				}
				return Promise.resolve(vfRedirect);
			}
			if (solutionName == EMS_COMPONENT_NAMES.solution) {
				console.log("Inside customAttributeEdit Guid--->" + configurationGuid);
				var url = "";
				var vfRedirect = "";
				var featureLevel = "";
				var techSupport = "";
				var type = "";
				var selectedTenancyIds = "";
                var offerId = "";//DPG-2319
                var prodSpecId = "";//DPG-2319
                var commercialProductId = "";//DPG-2319
                var jsonsios = "";//EDGE-178214
				var changeType ="";//EDGE-178214
				let currentBasket = await CS.SM.getActiveBasket();
				//Pooja summer 20 changes starts here
				//await CS.SM.getActiveSolution().then((solution) => {
				//let currentBasket = await CS.SM.getActiveBasket();
				//let solution = currentBasket.getActiveSolution(solutionName);
				let solution = await CS.SM.getActiveSolution();
				if (solution && solution.name.includes(EMS_COMPONENT_NAMES.solution)) {
					//changed solution.type to solution
					if (solution.components && Object.values(solution.components).length > 0) {
						Object.values(solution.schema.configurations).forEach((config) => {
							if (config.attributes && Object.values(config.attributes).length > 0) {
								Object.values(config.attributes).forEach((attr) => {
									if (attr.name === "TenancyID") {
										selectedTenancyIds = attr.value;
										console.log("selectedTenancyIds-->" + selectedTenancyIds);
									}
								});
							}
						});
						Object.values(solution.components).forEach((comp) => {
							if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 && (comp.schema.name.includes(EMS_COMPONENT_NAMES.userSupport) || comp.schema.name.includes(EMS_COMPONENT_NAMES.mobilityPlatformMgmt))) {
								Object.values(comp.schema.configurations).forEach((config) => {
									console.log("Inside customAttributeEdit Config Guid--->" + config.guid);
									if (config.guid === configurationGuid) {
										if (config.attributes && Object.values(config.attributes).length > 0) {
											Object.values(config.attributes).forEach((attr) => {
												if (attr.name === "Type") type = attr.value;
												if (attr.name === "TechnicalSupport") techSupport = attr.displayValue;
												if (attr.name === "FeatureLevel") featureLevel = attr.displayValue;
                            					if (attr.name === "OfferId") offerId = attr.displayValue;//DPG-2319
                            					if (attr.name === "ProductSpecId") prodSpecId = attr.displayValue;//DPG-2319
                                                if (attr.name === "json_sios") jsonsios = attr.value;//EDGE-178214 //EDGE-205510: Updated from displayValue to value
												if (attr.name === "ChangeType") changeType = attr.displayValue;//EDGE-178214
											});
											//Pooja summer 20 changes ends here
										}
									}
								});
							}
						});
					}
				}
				//DPG-2319 Start
                if(techSupport && featureLevel && prodSpecId){
					let currentBasket = await CS.SM.getActiveBasket();
                    let inputMap = {};
					inputMap["getCommercialProductId"] = techSupport+","+featureLevel+","+prodSpecId;
					await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
						commercialProductId = result["getCommercialProductId"];  
					});
				}
				//DPG-2319 End
				
				var redirectURI = "/apex/";
				if (communitySiteId) {
					url = window.location.href;
					//if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/"; //Replace /apex/(shresth)
					//redirectURI = '/partners/s/sfdcpage/%2Fapex%2F';  //EDGE -145320 >> -
					else redirectURI = "/partners/"; //EDGE -145320 >> +
				}
				url = redirectURI;
				//updated for EDGE-123914
				if (attributeName === "tmdmRateCardButton" && commercialProductId) {//DPG-2319(Added check for commercialProductId)
					if (communitySiteId) {
						/*Updated URL for EDGE-17821*/
						url = url + "c__RateMatrixForIoT?offerid=" + offerId + "&commProdId=" +commercialProductId + "&jsonsios="+jsonsios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName; //DPG-2319 //EDGE-178214
						// Updated for Edge-123607
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
					} else {
						/*Updated URL for EDGE-17821*/
						url = url + 'c__RateMatrixForIoT?offerid=' + offerId + '&commProdId=' +commercialProductId + "&jsonsios="+jsonsios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName; //DPG-2319 //EDGE-178214
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
					}
				} else if (attributeName === "endUserSupportRateCardButton" && commercialProductId) {
					if (communitySiteId) {
						/*Updated URL for EDGE-17821*/
						url = url + "c__RateMatrixForIoT?offerid=" + offerId + "&commProdId=" +commercialProductId + "&jsonsios="+jsonsios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName; //DPG-2319  //EDGE-178214
						vfRedirect = '<iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe>';
					} else {
						/*Updated URL for EDGE-17821*/
						url = url + "c__RateMatrixForIoT?offerid=" + offerId + "&commProdId=" +commercialProductId + "&jsonsios="+jsonsios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;  //DPG-2319  //EDGE-178214
						vfRedirect = '<iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="960px"></iframe>';
					}
				} else if (attributeName === "TenancyButton") {
					//console.log('basketId', basketId);
					//console.log('accountId', accountId);
					//console.log('TenancyId', selectedTenancyIds);
					var tenancyTypeProdIdList = ["DMCAT_ProductSpecification_000537"];
					if (communitySiteId) {
						url = url + "c__existingTenancy?basketId=" + basketId + "&accountId=" + accountId + "&filterByTenancyType=" + "true" + "&tenancyTypeProdIdList=" + tenancyTypeProdIdList + "&selectedTenancyIds=" + selectedTenancyIds;
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="850px"></iframe></div>';
					} else {
						url = url + "c__existingTenancy?basketId=" + basketId + "&accountId=" + accountId + "&filterByTenancyType=" + "true" + "&tenancyTypeProdIdList=" + tenancyTypeProdIdList + "&selectedTenancyIds=" + selectedTenancyIds;
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="850px"></iframe></div>';
					}
					//console.log('url: ', url);
					//console.log('Filter Values --->' + featureLevel + type);
					//vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="800px" width="800px"></iframe></div>';
					//console.log('vfRedirect--->' + vfRedirect);
				}
				return Promise.resolve(vfRedirect);
			}
			// IOT Sukul
			if (solutionName == IOTMobility_COMPONENTS.solution) {
				//Added logic for DPG-1964
				var url = "";
				var vfRedirect = "";
				var sol;
				var offerTypeName = "";
				var offerid = "";
				let product = await CS.SM.getActiveSolution();
				//await CS.SM.getActiveSolution().then((product) => {
				sol = product;
				//if (sol.type && sol.name === IOTMobility_COMPONENTS.solution) {
				if (sol.componentType && sol.name.includes(IOTMobility_COMPONENTS.solution)) {
					//sol.schema.configurations.forEach((config) => {
					Object.values(sol.schema.configurations).forEach((config) => {
						//config.attributes.forEach((priceItemAttribute) => {
						// Object.values(config.attributes).forEach((priceItemAttribute) => {
						//var offerString = config.attributes.filter(a => {
						let offerString = config.getAttribute("OfferTypeString");
						/*var offerString = Object.values(config.attributes).filter(a => {
							return a.name === 'OfferTypeString'
						});*/
						if (offerString && offerString) {
							offerTypeName = offerString.value;
						}
						let offerids = config.getAttribute("OfferId");
						/*var offerids = Object.values(config.attributes).filter(a => {
							return a.name === 'OfferId'
						});*/
						if (offerids && offerids) {
							offerid = offerids.value;
						}
						//  });
					});
				}
				//});
				//console.log('offerTypeName-->' + offerTypeName);
				//console.log('@@offerid@@' + offerid);
				if (attributeName === "IoTRateCardButton") {
					if (sharedDataPlan == offerTypeName) {
						url = url + "c__RateMatrixForIoT?CallingPlan=" + offerTypeName + "&offerid=" + offerid; //Edge-120919
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						//console.log('Url ---->', url);
					} else {
						url = "/resource/RateCard";
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="800px" width="820px"></iframe></div>';
						//console.log('url:', url);
					}
				}
				return Promise.resolve(vfRedirect);
			} // IOT Sukul
            
            if (solutionName == IOTCONNECTIVITY_COMPONENTS.solutionname) {
				//Added logic for DPG-1964
				var url = "";
				var vfRedirect = "";
				var sol;
				var offerTypeName = "";
				var offerid = "";
				var selectplanname = "";
                var solutionId = "";//Vamsi
                var guid = "";
                var changeType = "";
				let solution = await CS.SM.getActiveSolution();
                        solutionId = solution.solutionId;//Vamsi
                if (solution.components && Object.values(solution.components).length > 0) {
					let comp = solution.getComponentByName(IOTCONNECTIVITY_COMPONENTS.iotPlans);
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						let config = comp.getConfiguration(configurationGuid);
                        guid = config.guid;//Vamsi
                        var ChangeTypes = config.getAttribute("ChangeType");
                        changeType = ChangeTypes.value;//Vamsi
                        console.log(solutionID+guid+changeType);
						if (config.attributes && Object.values(config.attributes).length > 0) {
							let offerString = config.getAttribute("OfferTypeString");
							if (offerString && offerString) {
								offerTypeName = offerString.value;
							}
                        
							let offerids = config.getAttribute("OfferId");
							if (offerids && offerids) {
								offerid = offerids.value;
							}
							
							let selectplannames = config.getAttribute("select plan");
                        	if(selectplannames && selectplannames){
                        		selectplanname = selectplannames.displayValue;
                    		}
						}
					}
                // Added logic for DPG-5394 - Display Rate card and pricing summary
            	if (attributeName === "IoTPlansRateCardButton") {
					if (sharedDataPlan == offerTypeName) {
						url = url + "c__RateMatrixForIoT?CallingPlan=" + offerTypeName + "&offerid=" + offerid + "&selectplanname=" + selectplanname + "&solutionId=" + solutionId + "&guid=" + guid + "&changeType=" + changeType; //Edge-120919 //Vamsi
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						//console.log('Url ---->', url);
					} else {
                        url = "/resource/RateCard";
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="800px" width="820px"></iframe></div>';
						//console.log('url:', url);
					}
				}
				return Promise.resolve(vfRedirect);
			}
         }                  
			//NextGenFC Shresth(DPG- 2084)
			if (solutionName === NextGenFC_COMPONENTS.solution) {
				var url = "";
				var vfRedirect = "";
				var offerid = "";
				var vendor = "";
				let solutionId = "";
				configId = configurationGuid;
				var priceItemId = "";
				var BussinessId_Platform = "";
				var contractType = "";
				let product = await CS.SM.getActiveSolution();
				sol = product;
				if (sol.componentType && sol.name.includes(NextGenFC_COMPONENTS.solution)) {
					//sol.schema.configurations.forEach((config) => {
					Object.values(sol.schema.configurations).forEach((config) => {
						//config.attributes.forEach((priceItemAttribute) => {
						//Object.values(config.attributes).forEach((priceItemAttribute) => {
						offerid = config.getAttribute("OfferId");
						//var offerString = config.attributes.filter(a => {
						//offerid = Object.values(config.attributes).filter((attr) => {
						//return attr.name === 'OfferId'
						// });
						//});
					});
				}
				var redirectURI = "/apex/";
				if (communitySiteId) {
					url = window.location.href;
					//if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/"; //Replace /apex/(shresth)
					else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				if (attributeName === "ShowADPRateCard") {
					if (communitySiteId) {
						url = url + encodeURIComponent("c__RateMatrixForIoT?offerid=" + offerid.value);
					} else {
						url = "c__RateMatrixForIoT?offerid=" + offerid.value;
					}
					vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
					return Promise.resolve(vfRedirect);
				}
				/*
				 //Added for Promotions and discounts krunal
				if (attributeName === 'viewDiscounts') {
					//await CS.SM.saveSolution(true, true).then( solId => console.log(solId));
					pricingUtils.checkDiscountValidation(solution, 'IsDiscountCheckNeeded', TENANCY_COMPONENT_NAMES.tenancy);
					if (communitySiteIdUC) {
						url = '/partners/';
						url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId=' + solutionId + '&accessMode=ReadOnly' + '&customAttribute=' + attributeName + '&priceItemId=' + priceItemId[0].value + '&configId=' + configId + '&solutionName=Platform';
						vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
						console.log('Url ---->', url);
					} else {
						url = url + 'c__HandlingDiscounts?basketId=' + basketId + '&accountId=' + accountId + '&solutionId=' + solutionId + '&accessMode=ReadOnly' + '&customAttribute=' + attributeName + '&priceItemId=' + priceItemId[0].value + '&configId=' + configId + '&solutionName=Platform';
						vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						console.log('Url ---->', url);
					}
					console.log('vfRedirect--->' + vfRedirect);
				}
				//Added for Price Schedule krunal
				if (attributeName === 'Price Schedule') {
					if (communitySiteIdUC) {
						url = '/partners/';
						url = url + 'c__PriceSchedulePage?configId=' + configId + '&BussinessId_Device=' + BussinessId_Platform + '&solutionName=Platform' + '&contractType=' + contractType;
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
						console.log('Url ---->', url);
					} else {
						url = url + 'c__PriceSchedulePage?configId=' + configId + '&BussinessId_Device=' + BussinessId_Platform + '&solutionName=Platform' + '&contractType=' + contractType;
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						console.log('Url ---->', url);
					}
					console.log('vfRedirect--->' + vfRedirect);
				}
		*/
				return Promise.resolve(true);
			} //NextGenFC Shresth
			// CMP Arinjay
			if (solutionName === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				var url = "";
				var vfRedirect = "";
				var solutionId = "";
				let inputMap = {};
				//var solution=window.currentSolutionName;
				solutionName = "Enterprise Mobility";
				var selectplan;
				var internationalDirectDialIn;
				configId = configurationGuid;
				var BussinessId_PI = "";
				var BussinessId_Addon = "";
				var EmChangeType = ""; //Added by Aman Soni as a part of EDGE-123593
				//await CS.SM.getActiveSolution().then((product) => {
				// Spring 20
				let solution = await CS.SM.getActiveSolution();
				//solution = product;
				solutionId = solution.solutionId;
				if (solution.components && Object.values(solution.components).length > 0) {
					// Object.values(solution.components).forEach((comp) => {
					let comp = solution.getComponentByName(ENTERPRISE_COMPONENTS.mobileSubscription);
					// if (comp.name === ENTERPRISE_COMPONENTS.mobileSubscription) {
					if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						//Object.values(comp.schema.configurations).forEach((config) => {
						//if(config.guid === configurationGuid){
						let config = comp.getConfiguration(configurationGuid);
						if (config.attributes && Object.values(config.attributes).length > 0) {
							 selectplan = config.getAttribute("Select Plan");
							 oldplan = config.getAttribute("OldPlanTypeString");
							 oldIdd = config.getAttribute("OldIDD");
							 initDate = config.getAttribute("initialActivationDate");
							 internationalDirectDialIn = config.getAttribute("InternationalDirectDial");
							 BussinessId_PI = config.getAttribute("BussinessId_PI");
							 EmChangeType = config.getAttribute("ChangeType");
							 BussinessId_Addon = config.getAttribute("BussinessId_Addon");
							/*selectplan = Object.values(config.attributes).filter(a => {
								return a.name==='Select Plaoldplann' 
							});
							oldplan = Object.values(config.attributes).filter(a => {
								return a.name==='OldPlanTypeString' 
							});
							oldIdd = Object.values(config.attributes).filter(a => {
								return a.name==='OldIDD' 
							});
							initDate = Object.values(config.attributes).filter(a => {
								return a.name==='initialActivationDate' 
							});
							internationalDirectDialIn=Object.values(config.attributes).filter(a => {
								return a.name==='InternationalDirectDial' && a.value
							});
							BussinessId_PI = Object.values(config.attributes).filter(a => {
								return a.name==='BussinessId_PI'
							}); //Added by Aman Soni as a part of EDGE-123593 || Start
							EmChangeType = Object.values(config.attributes).filter(a => {
								return a.name==='ChangeType'
							}); //Added by Aman Soni as a part of EDGE-123593 || End
							BussinessId_Addon = Object.values(config.attributes).filter(a => {
								return a.name==='BussinessId_Addon'
							});*/
						}
						// }
						// });
					}
					// }
					//});
				}
				//});
				var priceItemId = "";
				var planName = "";
				var addOnName = "";
				//Added by Aman Soni as a part of EDGE-123593 || Start
				var oldPlanName = "";
				var oldIddName = "";
				var initialDate = "";
				var EmChangeTypeValue = "";
				if (EmChangeType && EmChangeType) {
					EmChangeTypeValue = EmChangeType.value;
				}
				if (oldplan && oldplan) {
					oldPlanName = oldplan.value;
				}
				if (oldIdd && oldIdd) {
					oldIddName = oldIdd.value;
				}
				if (initDate && initDate) {
					initialDate = initDate.value;
				}
				//console.log('oldPlanName-->'+oldPlanName+''+'oldIddName-->'+oldIddName);
				//Added by Aman Soni as a part of EDGE-123593 || End
				if (selectplan && selectplan) {
					priceItemId = selectplan.value;
					planName = selectplan.displayValue;
				}
				if (internationalDirectDialIn && internationalDirectDialIn) {
					//addonId=internationalDirectDialIn[0].value;
					addOnName = internationalDirectDialIn.displayValue;
				}
				//console.log('priceItemId-->'+priceItemId);
				//console.log('planName-->'+planName);
				//console.log('businessId-->'+businessId);
				var redirectURI = "/apex/";
				if (communitySiteId) {
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/s/sfdcpage/%2Fapex%2F";
					else redirectURI = "/partners/s/sfdcpage/%2Fapex%2F";
				}
				url = redirectURI;
				//console.log('@@@@attributeName--->'+attributeName);
				if (attributeName === "viewDiscounts") {
					if (communitySiteId) {
						url = "/partners/";
						url = url + "c__HandlingDiscounts?basketId=" + basketId + "&accountId=" + accountId + "&solutionId=" + solutionId + "&accessMode=ReadOnly" + "&customAttribute=" + attributeName + "&priceItemId=" + priceItemId + "&configId=" + configId + "&solutionName=" + solutionName;
						vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
						//console.log('Url ---->',url);
					} else {
						url = url + "c__HandlingDiscounts?basketId=" + basketId + "&accountId=" + accountId + "&solutionId=" + solutionId + "&accessMode=ReadOnly" + "&customAttribute=" + attributeName + "&priceItemId=" + priceItemId + "&configId=" + configId + "&solutionName=" + solutionName;
						vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						//console.log('Url ---->',url);
					}
					//vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="260px" width="820px"></iframe></div>';
					//console.log('vfRedirect--->'+vfRedirect);
				}
				if (attributeName === "Price Schedule") {
					if (communitySiteId) {
						url = "/partners/";
						url =
							url +
							"c__PriceSchedulePage?configId=" +
							configId +
							"&BussinessId_Addon=" +
							"&BussinessId_Addon=" +
							"&BussinessId_PI=" +
							BussinessId_PI +
							"&planName=" +
							planName +
							"&addOnName=" +
							addOnName +
							"&EmChangeTypeValue=" +
							EmChangeTypeValue +
							"&oldPlanName=" +
							oldPlanName +
							"&oldIddName=" +
							oldIddName +
							"&initialDate=" +
							initialDate; //Added EmChangeTypeValue,oldPlanName,initialDate and oldIddName by Aman Soni as a part of EDGE-123593
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="900px" width="820px"></iframe></div>';
						console.log("Url ---->", url);
					} else {
						url =
							url +
							"c__PriceSchedulePage?configId=" +
							configId +
							"&BussinessId_Addon=" +
							"&BussinessId_Addon=" +
							"&BussinessId_PI=" +
							BussinessId_PI +
							"&planName=" +
							planName +
							"&addOnName=" +
							addOnName +
							"&EmChangeTypeValue=" +
							EmChangeTypeValue +
							"&oldPlanName=" +
							oldPlanName +
							"&oldIddName=" +
							oldIddName +
							"&initialDate=" +
							initialDate; //Added EmChangeTypeValue,oldPlanName and oldIddName by Aman Soni as a part of EDGE-123593
						vfRedirect = '<div><iframe frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
						console.log("Url ---->", url);
					}
					//vfRedirect ='<div><iframe frameborder="0" scrolling="yes" src="'+ url +'" style="" height="260px" width="820px"></iframe></div>';
					// console.log('vfRedirect--->'+vfRedirect);
				}
				return Promise.resolve(vfRedirect);
			}
			// CMP Arinjay
			//Added below if condition as a part of EDGE-189788
			if (solutionName === TENANCY_COMPONENT_NAMES.solution && attributeName === "TMDMRateCard") {
				var vfRedirect = "";
				var offerid = "";
				var vendor = "";
				var json_sios = "";
				var changeType = "";
				url = window.location.href;
                var redirectURI = "/apex/";
				if (communitySiteId) {
					url = window.location.href;
					if (url.includes("partners.enterprise.telstra.com.au")) redirectURI = "/apex/";
					else redirectURI = "/partners/";
				}
				url = redirectURI;
				//get Basket Status
				var currentBasket = await CS.SM.getActiveBasket();
				let solution = await CS.SM.getActiveSolution();
				if (solution.componentType && solution.name.includes(TENANCY_COMPONENT_NAMES.solution)) {
					if (solution.components && Object.values(solution.components).length > 0) {
						let comp = solution.getComponentByName(componentName);
						if (comp) {
							let config = comp.getConfiguration(configurationGuid);
							if (config.attributes && Object.values(config.attributes).length > 0) {
								offerid = config.getAttribute("OfferId");
								vendor = config.getAttribute("Vendor");
								json_sios = config.getAttribute("json_sios");
								changeType = config.getAttribute("changetype");
								
							}
						}
					}
				}
				if(json_sios){
					json_sios = json_sios.value;
				}
				if(changeType){
					changeType = changeType.value;
				}
				/* DN: commented out; replaced by code below from master
				if (communitySiteId) {
					//url = "/partners/apex/"; // Commented as this will not work in Production
					url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;
					vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
					
				} else {
					url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName; //Added By Shresth DPG - 2084
					vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
				}
				*/
				//DN: code from master
				if (window.communitySiteId) {	
					//url = url + encodeURIComponent('c__StockCheckPage?basketID=' + basketId );
					var baseurl = window.location.href;
					if (baseurl.includes("partners.enterprise.telstra.com.au")) {
						url = "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;
						vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
					} else {
						url = "/partners/";
						url = url + ("c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName);
						vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
					}
					vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
				} else {
					url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;
					vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
				}
				
				return Promise.resolve(vfRedirect);
			}
			//TMDM If Condition ends here : EDGE-189788

			// Added by Nikhil as part of DIGI-603
			//29-10-2021 Added DMSRateCard in if condition by Srinivas from Radium team as a part of DIGI-32173 - Enable Sales incentives for DMS.
			if (solutionName === DMS_COMPONENT_NAMES.solution && attributeName === "DMSRateCard") {
				var vfRedirect = "";
				var offerid = "";
				var vendor = "";
				var json_sios = "";
				var changeType = "";
				url = window.location.href;
                var redirectURI = "/apex/";
				
				url = redirectURI;
				//get Basket Status
				var currentBasket = await CS.SM.getActiveBasket();
				let solution = await CS.SM.getActiveSolution();
				if (solution.componentType && solution.name.includes(DMS_COMPONENT_NAMES.solution)) {
					if (solution.components && Object.values(solution.components).length > 0) {
						let comp = solution.getComponentByName(componentName);
						if (comp) {
							let config = comp.getConfiguration(configurationGuid);
							if (config.attributes && Object.values(config.attributes).length > 0) {
								offerid = config.getAttribute("OfferId");
								json_sios = config.getAttribute("json_sios");
								changeType = config.getAttribute("changetype");


							}
						}
					}
				}
				if(json_sios){
					json_sios = json_sios.value;
				}
				if(changeType){
					changeType = changeType.value;
				}
				if (communitySiteId) {
					// url = url + "c__RateMatrixForIoT?offerid=" + offerid.value;// 29-10-2021 Commented as,we need to enable Expected SIO's in Ratecard
					// DIGI-32173 - Enable Sales incentives for DMS.
					url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName; 
					vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
					
				} else {
					//url = url + "c__RateMatrixForIoT?offerid=" + offerid.value;// 26-10-2021 Commented as,we need to enable Expected SIO's in Ratecard
					// DIGI-32173 - Enable Sales incentives for DMS.
					url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;
					vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
				}
				
				return Promise.resolve(vfRedirect);
			}
			//DMS if Condition ends here :DIGI-603
            // Added by Monali as part of DIGI-5561
			if (solutionName === EndpointLifecycle_COMPONENTS.solution) {
                var vfRedirect = "";
                var offerid = "";
                var vendor = "";
                var json_sios = "";
                var changeType = "";
                url = window.location.href;
                var redirectURI = "/apex/";
                
                url = redirectURI;
                //get Basket Status
                var currentBasket = await CS.SM.getActiveBasket();
                let solution = await CS.SM.getActiveSolution();
                
                if (solution.componentType && solution.name.includes(EndpointLifecycle_COMPONENTS.solution)) {
					if (solution.components && Object.values(solution.components).length > 0) {
						let comp = solution.getComponentByName(componentName);
						if (comp) {
							let config = comp.getConfiguration(configurationGuid);
							if (config.attributes && Object.values(config.attributes).length > 0) {
								offerid = config.getAttribute("OfferId");
								json_sios = config.getAttribute("json_sios");
								changeType = config.getAttribute("changetype");
								console.log('json_sios value:: '+json_sios);
							}
						}
					}
				}
                if (solution.components && Object.values(solution.components).length > 0) {
                    let comp = solution.getComponentByName(EndpointLifecycle_COMPONENTS.LifecycleManagement);
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                        let config = comp.getConfiguration(configurationGuid);
                        if (config.attributes && Object.values(config.attributes).length > 0) {
                             offerid = config.getAttribute("OfferId");
                            json_sios = config.getAttribute("json_sios");
                            changeType = config.getAttribute("changetype");
                            console.log('json_sios value:: '+json_sios);
                        }
                    }
                }
                if(json_sios){
                    json_sios = json_sios.value;
                    //json_sios = json_sios.displayvalue;
                }
                if(changeType){
                    changeType = changeType.value;
                }
				
				/* DN: commented out; replaced by code below from master
				if (communitySiteId) {
					url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;
					vfRedirect = '<div><iframe id="viewDiscounts" frameborder="0" scrolling="yes" src="' + url + '" style="" height="500px" width="820px"></iframe></div>';
					
				} else {
					url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;
					vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
				}
				*/
				//DN: code from master
                if (window.communitySiteId) {
                    //url = url + encodeURIComponent('c__StockCheckPage?basketID=' + basketId );
                    var baseurl = window.location.href;
                    if (baseurl.includes("partners.enterprise.telstra.com.au")) {
                        url = "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;
                        vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
                    } else {
                        url = "/partners/";
                        url = url + ("c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName);
                        vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
                    }
                    vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
                } else {
                    url = url + "c__RateMatrixForIoT?offerid=" + offerid.value +"&jsonsios="+json_sios+"&guid="+configurationGuid+"&changeType="+changeType+"&basketStage="+currentBasket.basketStageValue+"&compName="+componentName;                  
                    vfRedirect = '<div><iframe id="viewRateCard" frameborder="0" scrolling="yes" src="' + url + '" style="" height="470px" width="920px"></iframe></div>';
                }
                
                return Promise.resolve(vfRedirect);
            }
			//Lifecycle Management if Condition ends here :DIGI-5561
						//Start:DIGI-8814
						if(solutionName === ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname && attributeName == "SiteDetails") {
							let url			=	window.location.origin;
							let siteId 		= 	"";
							let solution	= 	await CS.SM.getActiveSolution();
							if (solution.components && Object.values(solution.components).length > 0) {
								let comp 	= 	solution.getComponentByName(ADAPTIVENETWORKS_COMPONENT_NAMES.solutionname);
								if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
									let config = comp.getConfiguration(configurationGuid);
									if (config.attributes && Object.values(config.attributes).length > 0) {
										let getSiteId	=	config.getAttribute("SiteId");
										siteId 			= 	getSiteId.value;
									}
								}
							}
							if(siteId) {
								if((window.location.href).includes('/partners/')) {
									url = url + "/partners/s/detail/" + siteId;
								} else{ 
									url = url + "/lightning/r/cscrm__Site__c/" + siteId + "/view";
								}
								window.open(url);
							}
							return Promise.resolve(true);	
						} 
						//End:DIGI-8814
		};
		// Arinjay Start Aug 12
		CS.SM.UIPlugin.afterNavigate = async function (currentComponent, previousComponent) {
            updateButtonConfigButtonVisibility(); // DIGI-14126
			let activeSolution = await CS.SM.getActiveSolution();
			if (activeSolution.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
				//EMPlugin_subscribeToExpandButtonEvents(currentComponent.name);
			}

			// else if (activeSolution.name === "Telstra Collaboration") {      DIGI-5648
			else if (activeSolution.name === NGUC_OFFER_NAME) {
				UCEPlugin_afterNavigate(currentComponent.name);
			}
			else if (activeSolution.name === NXTGENCON_COMPONENT_NAMES.nxtGenMainSol || activeSolution.name == "Device Outright Purchase") {
						//CommonUtills.lockSolution(); //EDGE-201407
                        Utils.updateImportConfigButtonVisibility();
			}
			
			if(!window.allowCommercialChanges)
			{
				CommonUtills.lockSolution();//For EDGE-207353 on 14APR2021 by Vamsi
			}
			//EDGE-204313 start
			if(window.basketType==='Incoming'){
				Utils.updateButtonVisibility('Add to Mac');
			}
		//EDGE-204313 end 
		//Kalashree EDGE-216668
            Utils.updateCustomButtonVisibilityForBasketStage();
			return Promise.resolve(true);
		};
		CS.SM.UIPlugin.beforeNavigate = function (currentComponent, previousComponent) {
			return Promise.resolve({ allow: true /*, message: 'Success beforeNavigate'*/ });
		};
		CS.SM.UIPlugin.onCustomAttributeFormat = async function (solutionName, componentName, configurationGuid, attributeName) {
			console.log(solutionName);
			console.log(componentName);
			console.log(attributeName);
			/*console.log(mapSolLinks[solutionName]);
			console.log(mapSolLinks[solutionName][componentName]);
			console.log(mapSolLinks[solutionName][componentName][attributeName]);*/
			let viewLabel = "View Details";
			if (mapSolLinks[solutionName]) {
				if (mapSolLinks[solutionName][componentName]) {
					if (mapSolLinks[solutionName][componentName][attributeName]) {
						viewLabel = mapSolLinks[solutionName][componentName][attributeName];
					}
				}
			}
			let data = "<button class='slds-button' >" + viewLabel + "</button>";
			this.customFormatter = data;
			return Promise.resolve(data);
		};
		// Arinjay End Aug 12
		CS.SM.registerUIPlugin();
	}
});
//Manuga Changes for Button EDGE-165017
const addCustomButtonSC = async () => {
	let elems = document.getElementsByClassName("slds-page-header__row");
	if (elems && elems.length > 0) {
		let row = elems[0];
		let overviewButton = document.createElement("button");
		overviewButton.innerHTML = "View Offer Information";
		overviewButton.classList = "slds-button slds-button_neutral";
		overviewButton.onclick = openPowerBIURL;
		overviewButton.Id = "ViewOfferInformation";
		overviewButton.style.margin = "10px";
		row.append(overviewButton);
		clearInterval(intervalFunc);
	}
};
const openPowerBIURL = async () => {
	let currentBasket = await CS.SM.getActiveBasket();
	let inputMap = {};
	inputMap["getLoginUserProfileName"] = "";
	await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
		let profilePRM = result["getLoginUserProfileName"];
		if (profilePRM.Name === "PRM Community User - Australia" || profilePRM.Name === "PRM Admin - Australia") {
			//172045 changes done for Partner URL by Aarathi
		    //window.open("https://partners.enterprise.telstra.com.au/s/category-landing?categoryName=Digitised_Products&defaultFieldValues=Products%2CDigitised_Products");
			//EDGE-190327
			var checkUrl = window.location.origin;
        	var appendUrl = "/partners/s/product-information";
        	var baseurl = checkUrl+appendUrl;
        	//alert('baseurl----->>>>>:'+baseurl);
        	window.open(baseurl);
		} else {
			window.open("https://app.powerbi.com/groups/me/apps/723cf694-d9b0-47e3-af72-342d382e61bc/dashboards/a358e75d-6471-4b9b-965d-5d171f8f3866");
		}
	});
};
//Manuga Changes for Button EDGE-165017
async function createBulkOE(solutionName, componentName) {
	if (Utils.isOrderEnrichmentAllowed()) isReadOnlyMode = false;
	console.log("createOEUI");
	bulkOEComponentName = componentName;
	deliveryDetailsHtml = "";
	deliveryDetailsAddressHtml = "";
	deliveryDetailsContactHtml = "";
	crdHtml = "";
	mfHtml = "";
	OESchemaIdMap = {};
	OEConfigurations = [];
	OEAddressSearchPhrase = "";
	OEContactSearchPhrase = "";
	OEAddressSearchResult = [];
	OEContactSearchResult = [];
	persistentValues = {};
	allOeValues = {};
	await populateSchemaIds();
	await fetchConfigurations();
	document.getElementsByClassName("slds-text-heading_medium")[0].style.display = "none";
	var table =
		'<div class="modal-header slds-modal__header">' +
		'<h2 class="title slds-text-heading--medium slds-hyphenate">' +
		'<div class="appLauncherModalHeader slds-grid slds-grid--align-spread  slds-m-right--small slds-m-left--small slds-grid--vertical-align-center slds-text-body--regular">' +
		"<div>" +
		'<h2 class="slds-text-heading--medium">Bulk Enrichment Console - ' +
		solutionName +
		"</h2>" +
		"</div>" +
		"<div>" +
		'<span class="icon-close" onclick="closeOe()" />' +
		"</div>" +
		"</div>" +
		"</h2>" +
		"</div>" +
		'</BR><div id="errorPannel" class="slds-theme_error"></div></BR>';
	table +=
		'<div class="slds-grid slds-gutters" >' +
		'<span class="slds-spinner_container" style="display: none; position:absolute; top:350px" id="main-save-spinner-1">' +
		'<div role="status" class="slds-spinner slds-spinner slds-spinner_large slds-spinner_brand">' +
		'<span class="slds-assistive-text">Saving</span>' +
		'<div class="slds-spinner__dot-a"></div>' +
		'<div class="slds-spinner__dot-b"></div>' +
		"</div>" +
		"</span>" +
		'<div class="slds-col slds-size_3-of-6" onmousemove="handlemousemove(event)" onmouseup="handlemouseup(event)">' +
		'<div class="slds-grid slds-gutters" style="margin-bottom: 10px">' +
		'<div class="slds-col ">SELECT IOT SUBSCRIPTIONS</div> ' +
		'<div class="slds-col ">' +
		'<input class="slds-input " type="text" placeholder="Search..." id="configurationSearch" attName="configurationSearch" value=""' +
		'  onkeyup="configurationSearchKeyUp(event)" /> ' +
		"</div>" +
		"</div>" +
		'<div class="slds-table_header-fixed_container slds-border_top slds-border_bottom slds-border_right slds-border_left" style="height:180px;">' +
		'<div id="tableViewInnerDiv" class="slds-scrollable_y tableViewInnerDiv" style="height:100%;">' +
		'<table aria-multiselectable="true" role="grid" class="slds-table slds-table_header-fixed  slds-table_bordered  slds-table_fixed-layout slds-table_resizable-cols">' +
		"<thead>" +
		'<tr class="">';
	if (!isReadOnlyMode) {
		table +=
			'<th   scope="col" style="width:32px">' +
			'<span id="column-group-header" class="slds-assistive-text">Choose a row</span>' +
			'<div class="slds-th__action slds-th__action_form slds-align_absolute-center slds-cell-fixed">' +
			'<div class="slds-checkbox ">' +
			'<input type="checkbox" class="pc-selection_all" name="options" id="checkboxAll" value="checkboxAll" tabindex="-1" aria-labelledby="check-select-all-label column-group-header"  onclick="updateSelectAll()" />' +
			'<label class="slds-checkbox__label" for="checkboxAll" id="check-select-all-label">' +
			'<span class="slds-checkbox_faux"></span>' +
			'  <span class="slds-form-element__label slds-assistive-text">Select All</span>' +
			"</label>" +
			"</div>" +
			"</div>" +
			"</th>";
	}
	table +=
		' <th aria-label="Name" aria-sort="none" class="slds-is-resizable dv-dynamic-width"  style="text-align:center; width: 350px" scope="col">' +
		' <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center dv-dynamic-width" style="width: 350px">' +
		'   <span class="slds-truncate">&nbsp;&nbsp;&nbsp;Name</span>' +
		'<div class="slds-resizable">' +
		'<span class="slds-resizable__handle" onmousedown="handlemousedown(event)">' +
		'<span class="slds-resizable__divider"></span>' +
		"</span>" +
		"</div>" +
		"</div>" +
		" </th>" +
		' <th aria-label="Model" aria-sort="none" class="slds-is-resizable" style="text-align:center" scope="col">' +
		'    <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center slds-align_absolute-center">&nbsp;&nbsp;&nbsp;Model</div>' +
		"  </th>" +
		"</tr>" +
		"</thead>" +
		'<tbody id="config_table_scrollable_container">';
	table += createConfigTableRows();
	table += "</tbody>" + "</table>" + "</div>" + "</div>";
	table +=
		"</div>" +
		'<div class="slds-col slds-size_3-of-6" id="main-nav-div-1">' +
		'<div class="slds-path">' +
		'  <ul class="slds-path__nav" role="listbox">' +
		'    <li class="slds-path__item slds-is-complete slds-is-active" title="Delivery Details" role="presentation" onclick="setActive(this)">' +
		'      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="0" aria-selected="true" aria-controls="oe-tab-default-1" name="Delivery details" id="oe-tab-default-1__item">Delivery Details</a>' +
		"    </li>" +
		'    <li class="slds-path__item slds-is-complete " title="Customer Requested Dates" role="presentation" onclick="setActive(this)">' +
		'      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-2" name="Customer requested Dates" id="oe-tab-default-2__item">Customer Requested Dates</a>' +
		"    </li>" +
		"  </ul>" +
		'  <div id="oe-tab-default-1" class="slds-tabs_default__content slds-show" role="tabpanel" aria-labelledby="oe-tab-default-1__item"><div id="delivery_oe"></div></div>' +
		'  <div id="oe-tab-default-2" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-2__item"><div id="crd_oe"></div></div>' +
		"</div>" +
		"</div>" +
		"</div>" +
		// + '<div class="modal-header slds-modal__header">'
		"</div>";
	if (!isReadOnlyMode) {
		table += '<div style="margin-top: 10px;  margin-bottom: 10px">' + '<button class="slds-button slds-button_neutral slds-float_right"  onclick="saveOEForSelectedConfigs(true)">Save & Close</button>' + '<button class="slds-button slds-button_neutral slds-float_right" onclick="saveOEForSelectedConfigs(false)">Save</button>' + "</div>";
	}
	var container = document.getElementsByClassName("container");
	container[0].innerHTML = table.trim();
	container[0].style.padding = "15px";
	prepareDeliveryDetails();
	//crdHtml = await prepareOETable('Customer requested Dates Mobility');
	crdHtml = await prepareOETable("Customer requested Dates");
	//fHtml = await prepareOETable('Mobility features');
	document.getElementById("oe-tab-default-2__item").click();
	document.getElementById("oe-tab-default-1__item").click();
}
// Added as part of EDGE_140968 - Start
getOfferIdValue = async function () {
	var offerIdValue;
	//Changes as part of EDGE-155255 start
	//await CS.SM.getActiveSolution().then(product => {
	let product = await CS.SM.getActiveSolution();
	if (product && product.name.includes(TID_COMPONENT_NAMES.solution)) {
		//changed product.type to product
		if (product.schema && product.schema.configurations && Object.values(product.schema.configurations).length > 0) {
			//EDGE-154495
			var offerIdAttArray = Object.values(Object.values(product.schema.configurations)[0].attributes).find((att) => {
				//RF++
				return att.name === "OfferId";
			});
			if (offerIdAttArray && offerIdAttArray.length > 0) {
				var offerIdAtt = offerIdAttArray[0];
				if (offerIdAtt && offerIdAtt.value) {
					offerIdValue = offerIdAtt.value;
				}
			}
		}
	}
	//});//Changes as part of EDGE-155255 end
	return offerIdValue;
};
// Added as part of EDGE_140968 - end
///////////////////////added by Rohit
UCEPlugin_afterNavigate = function (currentComponentName) {
	//console.log('Inside afterNavigate' + currentComponentName);
	//subscribeToExpandButtonEvents(currentComponentName);
	//Addde  for 138001
	//setTimeout(function () {
	Utils.updateImportConfigButtonVisibility();
	pricingUtils.updateGenerateNetPriceButtonVisibility("getPriceScheduleAPI");
	pricingUtils.updateGenerateNetPriceButtonVisibility("getPriceScheduleAPIAccessory");
    updateButtonConfigButtonVisibility(); // DIGI-14126
	//}, 50);
};
/*********************************************************************************************
 * Author	   : Vivek
 * Method Name : updateButtonConfigButtonVisibility
 * DIGI-14126
**********************************************************************************************/
updateButtonConfigButtonVisibility = async function () {
    // DIGI-14126 : vivek
    var OpportunityType ;
    let currentBasket = await CS.SM.getActiveBasket();
    basketId = currentBasket.basketId;

    let inputMap = {};
    inputMap["GetBasket"] = basketId;

     await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then(async (result) => {
        var basket = JSON.parse(result["GetBasket"]);
        OpportunityType = basket.Opportunity_Type__c;
        console.log('GetBasket: ', basket.Opportunity_Type__c );
    });


    if ( OpportunityType == 'CHOWN'){
        var buttons = document.getElementsByClassName('cs-btn');
        for(var i = 0; i < buttons.length; i++){
          if( buttons[i].innerText == 'Order Enrichment Console'){
            buttons[i].style.display = "none";
          }
        } 
    }

	if(window.basketType !='Incoming' && window.basketType != null){
		var buttons = document.getElementsByClassName('cs-btn');
				  for(var i = 0; i < buttons.length; i++){
						 if( buttons[i].innerText == 'Get Term and Amount'){
						 buttons[i].style.display = "none";
							}
			  }
		}
	
};
