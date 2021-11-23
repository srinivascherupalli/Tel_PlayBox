/*
 * Handles all UI-related logic
/*******************************************************************************************************************************************
Sr.No.		Author 			    Date	        Sprint   	     Story number		Description
1.		Srujana	Druvasula    15-Dec-2020	   20.16(New JS)	   P2OB-		    Current Product Catalog JS
2.		Ramcharan Patidar    30-Dec-2020	   20.18		       P2OB-11803		Business Rule for making Total Cost mandatory for Purple Product Category immediately
3.      Ramcharan Patidar    04-Jan-2020       20.18			   P2OB-11779       Business Rules for Partner. Make Partner mandatory based on Channel
4. 		Ramcharan Patidar    28-Jan-2020	   21.01	           P2OB-11856       <Cloudsense> <Solution Console> Updates in Domain or Product Family dropdown must reset the next dropdown(s)
5. 		Srujana	Druvasula    29-Jan-2020	   21.02	           P2OB-11769       <Cloudsense><Solution Console> Business Rules for Renewal Revenue
6. 		Ramcharan Patidar    30-Jan-2020	   21.02	           P2OB-12127       <Cloudsense><Solution Console> Layout changes for Solution Console
7. 		Ramcharan Patidar    31-Jan-2020	   21.02	           P2OB-11772       <Cloudsense><Solution Console> Business Rules for Recurring Charge (RC)
8.      Shishir Pareek       27-Jan-2021       21.02               P2OB-11727       <Cloudsense><Solution Console> Solution management enablement in product basket for add/view/edit of solutions
9.      Prince Malik         10-Feb-2021       21.02               P2OB-12473       <Cloudsense><Solution Console> Gross margin % should be rounded to 2 decimal places
10.     Ramcharan Patidar    12-Feb-2020       21.02               P2OB-12671       <CloudSense> Standard Solution | QA2 org | Conditional mandatory on Total Cost must be shown with a Red icon when product category is Purple
11. 	Srujana Durvasula	 22-Feb-2020	   21.03			   P2OB-12868		<Cloudsense><Solution Console> SPCSchema Label to be renamed to Standard Product Solution
12. 	Srujana Durvasula	 23-Feb-2020	   21.03			   P2OB-12668		<Cloudsense><Solution Console> Quantity and Term has to be whole number and rounded	
12. 	Srujana Durvasula	 23-Feb-2020	   21.03			   P2OB-12638		<Cloudsense><Solution Console> All the revenue fields to be rounded to 2 decimal places
13.     Shishir Pareek       24-Feb-2021       21.03               P2OB-12535       <Cloudsense><Solution Console> Gross margin should be rounded to 2 decimal places
14. 	Srujana Durvasula	 26-Feb-2020	   21.03			   P2OB-12564		<Cloudsense><Solution Console> Display the Product Code in the Solution Console after product selection
15.     Ramcharan Patidar    01-March-2021     21.03               P2OB-12186       <Cloudsense><Solution Console> New Business Rule for Opportunities having Partner Account
16. 	Srujana Durvasula	 3-March-2020	   21.03			   P2OB-13108       <CloudSense> Standard Solution | QA2 org | Gross Margin should not appear as NAN on Solution management on default.
17.     Ramcharan Patidar    05-March-2021     21.03               P2OB-13106       <CloudSense> Standard Solution | QA2 org | Direct Channel on save is enabling user to enter Partner details
18.     Ramcharan Patidar    08-March-2021     21.03               P2OB-13246       <CloudSense><Regression> Standard Solution | QA2 org | Product value gets reset when reset is done in another product line item
19.     Shishir Pareek       09-March-2021     21.04               P2OB-12497       <Cloudsense><Fastlane> "Product Description" for a product must be editable
20.     Shishir Pareek       15-March-2021     21.03               P2OB-13497       <Cloudsense><Fastlane>Indirect channel doesn't make Partner mandatory
21.     Shishir Pareek       18-March-2021     21.04               P2OB-13507       <CloudSense><Regression><Fastlane>'Error updating attribute' when putting a value into the 
																					Solution Name on the first chevron
22.     Sachin Dubey         05-April-2021     21.05               P2OB-11731       <Cloudsense><Solution Console> Warning message for Products with tags "Cease Sale"
23.     Shishir Pareek       30-March-2021     21.04               P2OB-13156       <CloudSense><Solution Console> Addition of new fields in the Product Configuration of Solution Console
24.     Ramcharan Patidar    29-April-2021     21.06               P2OB-13549       <Cloudsense><Solution Console> Selection of Product without selecting the Product Domain in Solution Console for Standard Products
25.     Shishir Pareek       09-July-2021      21.10               P2OB-15267       <CloudSense><Regression>Product description is not getting deleted from solution management
26.     Shishir Pareek       09-July-2021      21.10               P2OB-15636       <CloudSense><Regression>Competitor attribute is still visible from the solution console
27. 	Aman Soni	    	 22-July-2021      21.10		   	   P2OB-12565	    <Cloudsense><Solution Console> Calculate Total Cost based on Gross Margin (%)
28. 	Aman Soni	    	 22-July-2021      21.10		       P2OB-13501       <CloudSense><Regression>Gross Margin % is randomly not recalculating at times. Issue seems to be when % is to be calculated as 0.00
29.     Gokul             	 12-Aug-2021       21.11               DIGI - 7020      <Cloudsense><Solution Console> Added logic to calculate Gross margin and Total cost  
30.     Ramcharan            08-Nov-2021       21.15               NC000097601288   <Cloudsense><Solution Console> Added logic to Gross margin(%) is required instead of Total cost   
31.	    Ramcharan            11-Nov-2021       21.15               DIGI-38236       <CloudSense><Regression><Purple Product>Gross Margin(%) error message is removed on enter/edit any other input field(other than GM(%))  <Cloudsense><Solution Console> Added logic to Gross margin(%) is required instead of Total cost   
32.		Ramcharan/Don         15-Nov-2021      21.16               DIGI-39834       <CloudSense><Regression>Total Cost is not updating on QA1 for std oppty
**********************************************************************************************/
console.log('[CurrProdCat_UI] loaded');

const AN_UI = {};

AN_UI.afterConfigurationAdd = async function(guid) {
	try {
		let solution = await CS.SM.getActiveSolution();
		let stdProdComp = solution.getComponentBySchemaName(AN_COMPONENTS.StandardProduct);
		let config = Object.values(solution.getConfigurations())[0];
		let updateMap = {};
		updateMap[guid] = [];
		let configs = solution.getConfiguration(guid.guid);
		let attrList1;
		let updateMap1 = new Map();

		//Populate SRVList value from Opportunity Start
		if (solution.name.includes("Standard Product Solution")) {
			if (stdProdComp && stdProdComp.schema && stdProdComp.schema.configurations && Object.values(stdProdComp.schema.configurations).length > 0) {
				attrList1 = [{
					name: 'srvListString',
					value: SRVList,
					displayValue: SRVList
				}];
				//P2OB-13156 changes start
				Object.values(stdProdComp.schema.configurations).forEach(async (devConfigToUpdate) => {
					let accountIdAttribute = devConfigToUpdate.getAttribute("AccountId");
					
					if (accountIdAttribute != null && accountIdAttribute != undefined && accountIdAttribute.name === "AccountId") {
						if (accountId != null && accountId != '' && accountId != undefined) {
							updateMap1.set(devConfigToUpdate.guid, [{
								name: accountIdAttribute.name,
								value: accountId
							}]);
						}
						if (updateMap1) {
							updateMap1.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					let siteAttribute = devConfigToUpdate.getAttribute("Site");
					
					if (siteAttribute.name === "Site") {
						if (createdByUser != null && createdByUser != '' && createdByUser != undefined &&
							createdByUser === 'TESA Integration User') {
							updateMap1.set(devConfigToUpdate.guid, [{
								name: siteAttribute.name,
								readOnly: true
							}]);
						}
						if (updateMap1) {
							updateMap1.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (devConfigToUpdate.getAttribute("ShowSiteLookupAttribute").value) {
						let installationAddressAttribute = devConfigToUpdate.getAttribute("InstallationAddress");
						let siteAttribute = devConfigToUpdate.getAttribute("Site");
						
						if (installationAddressAttribute != null && installationAddressAttribute != undefined &&
							siteAttribute != null && siteAttribute != undefined) {
							updateMap1.set(devConfigToUpdate.guid, [{
								name: installationAddressAttribute.name,
								showInUi: false
							}, {
								name: siteAttribute.name,
								showInUi: true
							}]);
						}
						if (updateMap1) {
							updateMap1.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					} else if (!devConfigToUpdate.getAttribute("ShowSiteLookupAttribute").value) {
						let installationAddressAttribute = devConfigToUpdate.getAttribute("InstallationAddress");
						let siteAttribute = devConfigToUpdate.getAttribute("Site");
						
						if (installationAddressAttribute != null && installationAddressAttribute != undefined &&
							siteAttribute != null && siteAttribute != undefined) {
							updateMap1.set(devConfigToUpdate.guid, [{
								name: installationAddressAttribute.name,
								showInUi: true
							}, {
								name: siteAttribute.name,
								showInUi: false
							}]);
						}
						if (updateMap1) {
							updateMap1.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
				}); //P2OB-13156 changes end
			}
		}
		configs = stdProdComp.updateConfigurationAttribute(configs.guid, attrList1).then((configs) => {
			console.log("Updated configuration " + configs.guid);
		});
	} catch (error) {
		console.log('[CurrProdCat_UI] afterConfigurationAdd() exception: ' + error);
		return false;
	}
	return true;
};

AN_UI.afterAttributeUpdated = async function(configuration, attribute, oldValueMap) {
	try {
		let solution = await CS.SM.getActiveSolution();
		let stdProdComp = solution.getComponentBySchemaName(AN_COMPONENTS.StandardProduct);
		let config = Object.values(solution.getConfigurations())[0];
		let doUpdate = false;
		let ProdQtyUpdate = false;
		let revenueUpdate = false;
		let prodUpdate = false;
		let totalCostMedetory = false; //P2OB-12671
		let newValue = attribute.value; //changes related to P2OB-11856
		let oldValue = oldValueMap["value"]; //changes related to P2OB-11856
		let qtychaged = false;
		let oldqtyval = '';
		let renrevchaged = false;
		let RRattributeval1 = '';
		let rcrevchaged = false;
		let RCOLDattributeval = '';
		let isProductChanged = false;
		let isProductDescriptionToUpdateToNull = false;
		
		if (oldValueMap["name"] === "Quantity") {
			if (newValue != oldValue) {
				qtychaged = true;
				oldqtyval = oldValueMap["value"];
			}
		}
		if (oldValueMap["name"] === "RenewalRevenue") {
			if (newValue != oldValue) {
				renrevchaged = true;
			}
		}
		if (oldValueMap["name"] === "RC") {
			if (newValue != oldValue) {
				rcrevchaged = true;
			}
		}
		if (oldValueMap["name"] === "Product_SC") {
			if (newValue != oldValue) {
				isProductChanged = true;
			}
		}
		if (oldValueMap["name"] === "ProductDescription") {
			if (newValue != null && newValue != '' && newValue != oldValue) {
				isProductDescriptionToUpdateToNull = false;
			} else if((newValue === null || newValue === '') && newValue != oldValue) {
				isProductDescriptionToUpdateToNull = true;
			}
		}
		if (attribute.name === "Domain_SC" || attribute.name === "Product_SC") {
			doUpdate = true;
		}
		if (attribute.name === "Product_SC") {
			prodUpdate = true;
		}
		if (attribute.name === "Quantity" || attribute.name === "Product_SC") {
			ProdQtyUpdate = true; //P2OB-11769
		}
		if (attribute.name === "rc" || attribute.name === "renewalrevenue") {
			revenueUpdate = true; //P2OB-11769
		}
		//P2OB-11731 started
		if (prodUpdate === true) {
			let productName = configuration.attributes.product_sc.displayValue;
			
			if (productName.includes("Cease Sale ")) {
				if (oldValueMap["name"] === "Product_SC") {
					if ((newValue != oldValue) && newValue != "" && oldValue == "") {
						isCeaseSaleFlagOn = false; //P2OB-11731
					}
				}
			}
		} //P2OB-11731 end
		let updateMap = new Map();
		let resetLookupMap = new Map();
		let resetProductDependedAttributeMap = new Map();
		let updateTotalCostMap; //= new Map();	//DN: commented out
		let updateGrossMarginMap = new Map();
		let updateTotalCostMedetoryAttributeMap = new Map(); //P2OB-12671
		let updatePartnerChannelValueMap = new Map();
		
		if (solution.name === 'Standard Product Solution') {
			if (stdProdComp.schema && stdProdComp.schema.configurations && Object.values(stdProdComp.schema.configurations).length > 0) {
				Object.values(stdProdComp.schema.configurations).forEach(async (devConfigToUpdate) => {
					if (devConfigToUpdate.attributes.oc.value > 0 || devConfigToUpdate.attributes.rc.value > 0 || devConfigToUpdate.attributes.renewalrevenue.value > 0 || devConfigToUpdate.attributes.techtransrevenue.value > 0) {
						deviceConfigToUpd = devConfigToUpdate.guid;
						devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
						
						if (deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === "")) {
							let cnfg = await stdProdComp.getConfiguration(deviceConfigToUpd);
							cnfg.status = true;
							cnfg.statusMessage = "";
						}
					} else if (devConfigToUpdate.attributes.oc.value <= 0 && devConfigToUpdate.attributes.rc.value <= 0 && devConfigToUpdate.attributes.renewalrevenue.value <= 0 && devConfigToUpdate.attributes.techtransrevenue.value <= 0) {
						deviceConfigToUpd = devConfigToUpdate.guid;
						devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
						
						if (deviceConfigToUpd && (devReplaceConfigToUpd === undefined || devReplaceConfigToUpd === null || devReplaceConfigToUpd === "")) {
							let cnfg = await stdProdComp.getConfiguration(deviceConfigToUpd);
							cnfg.status = false;
							cnfg.statusMessage = "Please enter a value in at least one of the following revenue fields: Once Off, Incremental Annuity, Technology Transformation and Renewal Revenue.";
						}
					}
					//P2OB-11731 started
					let productName = configuration.attributes.product_sc.displayValue;
					
					if (productName.includes("Cease Sale ") && isCeaseSaleFlagOn === false) {
						isCeaseSaleFlagOn = true;
						CS.SM.displayMessage("You have selected a passive cease sale product. Passive cease sale products are not available for sale to new customers. Check the Product Migrations & Exits content in Solutions Catalogue for the recommended go-to product .<a href = https://teamtelstra.sharepoint.com/:x:/r/sites/TelstraSimplification/_layouts/15/Doc.aspx?sourcedoc=%7B21B63AC7-07A4-4B10-A042-F95BA8AAE898%7D&file=Overview%20cross-portofilo%20exit%20dates.xlsx&action=default&mobileredirect=true&cid=31cc07d1-fd67-4601-b319-5b10afbfbc77&CID=17C4A32C-AC8A-4DFA-8D13-223A23676A17&wdLOR=c22099613-1EEE-4F40-A70C-969C006B519E> More Information </a>", "info");
					} //P2OB-11731 ended
					if (oldqtyval != '') {
						RRattributeval1 = (devConfigToUpdate.attributes.srm.value * oldqtyval);
					}
					//P2OB-11769 <Cloudsense><Solution Console> Business Rules for Renewal Revenue Start				
					if (OptyType === "Renewal") {
						if (devConfigToUpdate.attributes.renewalrevenue.value == '' && devConfigToUpdate.attributes.srm.value >= 0) {
							if (qtychaged === true || prodUpdate === true) {
								let RRattribute = devConfigToUpdate.getAttribute("renewalrevenue");
								let RRattributeval = (devConfigToUpdate.attributes.srm.value * devConfigToUpdate.attributes.quantity.value);
								updateMap.set(devConfigToUpdate.guid, [{
									name: RRattribute.name,
									value: RRattributeval,
									showInUi: true,
									readOnly: false
								}]);
							}
						} else if (devConfigToUpdate.attributes.renewalrevenue.value == RRattributeval1 && devConfigToUpdate.attributes.srm.value >= 0 && renrevchaged === false) {
							if (qtychaged === true) {
								let RRattribute = devConfigToUpdate.getAttribute("renewalrevenue");
								let RRattributeval = (devConfigToUpdate.attributes.srm.value * devConfigToUpdate.attributes.quantity.value);
								updateMap.set(devConfigToUpdate.guid, [{
									name: RRattribute.name,
									value: RRattributeval,
									showInUi: true,
									readOnly: false
								}]);
							}
						}
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (oldqtyval != '') {
						RCOLDattributeval = (devConfigToUpdate.attributes.srm.value * oldqtyval);
					}
					if (OptyType === "MACs (Moves, Adds & Change)" || OptyType === "New To Market" || OptyType === "Price Review" || OptyType === "RFI") {
						let rcAttribute = devConfigToUpdate.getAttribute("rc");
						let rcAttributevalue = (devConfigToUpdate.attributes.srm.value * devConfigToUpdate.attributes.quantity.value);
						
						if (devConfigToUpdate.attributes.srm.value >= 0 && devConfigToUpdate.attributes.rc.value == '') {
							if (qtychaged === true || prodUpdate === true) {
								let rcAttributevalue = (devConfigToUpdate.attributes.srm.value * devConfigToUpdate.attributes.quantity.value);
								updateMap.set(devConfigToUpdate.guid, [{
									name: rcAttribute.name,
									value: rcAttributevalue,
									showInUi: true,
									readOnly: false
								}]);
							}
						} else if (devConfigToUpdate.attributes.rc.value == RCOLDattributeval && devConfigToUpdate.attributes.srm.value >= 0 && renrevchaged === false) {
							let rcAttributevalue = (devConfigToUpdate.attributes.srm.value * oldValue);
							
							if (devConfigToUpdate.attributes.rc.value != "" && oldValue != newValue && oldValue != "") {
								let rcAttributevalue = (devConfigToUpdate.attributes.srm.value * devConfigToUpdate.attributes.quantity.value);
								updateMap.set(devConfigToUpdate.guid, [{
									name: rcAttribute.name,
									value: rcAttributevalue,
									showInUi: true,
									readOnly: false
								}]);
							}
						}
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					} //P2OB-11772 <Cloudsense><Solution Console> Business Rules for Recurring Charge (RC) End
					//changes related to P2OB 11803 start && Defect P2OB-12671
					//Updated by Aman Soni for P2OB-12565 to make GrossMargin_Pct mandatory for Purple Products in place of Total Cost attribute || 
					if (devConfigToUpdate.attributes.productcategoryvalue.value === "Purple"){
						let attribute = devConfigToUpdate.getAttribute("GrossMargin_Pct");
						deviceConfigToUpd = devConfigToUpdate.guid;
						devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
						updateTotalCostMedetoryAttributeMap.set(devConfigToUpdate.guid, [{
							name: attribute.name,
							value: attribute.value,
							showInUi: true,
							readOnly: false,
							required: true
						}]);
						//changes related to DIGI-38236 start
						if(attribute.value === ''){
							devConfigToUpdate.status = false;
							devConfigToUpdate.statusMessage = 'Please enter GrossMargin(%)';
                        }
						//changes related to DIGI-38236 End
					} else {
						let attribute = devConfigToUpdate.getAttribute("GrossMargin_Pct");
						deviceConfigToUpd = devConfigToUpdate.guid;
						devReplaceConfigToUpd = devConfigToUpdate.replacedConfigId;
						updateTotalCostMedetoryAttributeMap.set(devConfigToUpdate.guid, [{
							name: attribute.name,
							value: attribute.value,
							showInUi: true,
							readOnly: false,
							required: false
						}]);
					}
					if (updateTotalCostMedetoryAttributeMap) {
						updateTotalCostMedetoryAttributeMap.forEach(async (v, k) => {
							await stdProdComp.updateConfigurationAttribute(k, v, true);
						});
					} //changes related to P2OB-11803 & Defect P2OB-12671 End
					// Updated by Gokul for  DIGI - 7020 to calcluate gross margin and total cost
					let grossMargin = devConfigToUpdate.getAttribute("GrossMargin_Pct");
					if (grossMargin !== undefined && grossMargin.value ){
						let oc = parseFloat(devConfigToUpdate.getAttribute("OC").value) || 0;
						let rc = parseFloat(devConfigToUpdate.getAttribute("RC").value) || 0;
						let techTransRevenue = parseFloat(devConfigToUpdate.getAttribute("TechTransRevenue").value) || 0;
						let renewalRevenue = parseFloat(devConfigToUpdate.getAttribute("RenewalRevenue").value) || 0;
						let grossProfit = devConfigToUpdate.getAttribute("GrossMargin");
						let grossMarginValue = (Number((parseFloat(grossMargin.value) || 0) * (oc + rc + techTransRevenue + renewalRevenue))/100).toFixed(2);
						let attribute = devConfigToUpdate.getAttribute("TotalCost");
						let totalCost = ((oc + rc + techTransRevenue + renewalRevenue) - parseFloat(grossMarginValue)).toFixed(2);
						totalCost = totalCost==-0.0 ? 0.0.toFixed(2) : totalCost
						
						//DN: commented out to fix TotalCost not getting updated in the UI DIGI-39834
						/* updateTotalCostMap.set(devConfigToUpdate.guid, [{
							name: attribute.name,
							value: totalCost,
							showInUi: true,
							readOnly: true,
							required: false
						}, {
							name: grossProfit.name,
							value: grossMarginValue,
							showInUi: true,
							readOnly: true,
							required: false
						}]);*/
						
						//DN: alternative solution DIGI-39834
						updateTotalCostMap = [{
							name: attribute.name,
							value: totalCost,
							showInUi: true,
							readOnly: true,
							required: false
						}, {
							name: grossProfit.name,
							value: grossMarginValue,
							showInUi: true,
							readOnly: true,
							required: false
						}];
					} else {
						let nullValue = null;
						let attribute1 = devConfigToUpdate.getAttribute("TotalCost");
						let grossProfit1 = devConfigToUpdate.getAttribute("GrossMargin");
						
						//DN: commented out to fix TotalCost not getting updated in the UI DIGI-39834
						/* updateTotalCostMap.set(devConfigToUpdate.guid, [{
							name: attribute1.name,
							value: nullValue,
							showInUi: true,
							readOnly: true,
							required: false
						},{
							name: grossProfit1.name,
							value: nullValue,
							showInUi: true,
							readOnly: true,
							required: false
						}]);*/
						
						//DN: alternative solution DIGI-39834
						updateTotalCostMap = [{
							name: attribute1.name,
							value: nullValue,
							showInUi: true,
							readOnly: true,
							required: false
						}, {
							name: grossProfit1.name,
							value: nullValue,
							showInUi: true,
							readOnly: true,
							required: false
						}];    
					}
					console.log('updateTotalCostMap***---',updateTotalCostMap)
					
					if (updateTotalCostMap) {
						//DN: commented out to fix TotalCost not getting updated in the UI DIGI-39834
						/* updateTotalCostMap.forEach(async (v, k) => {
							await stdProdComp.updateConfigurationAttribute(k, v, true);
						});*/
						
						//DN: alternative solution DIGI-39834
						let rfConfigs = stdProdComp.updateConfigurationAttribute(devConfigToUpdate.guid, updateTotalCostMap).then((rfConfigs) => {
							console.log("Updated configuration " + rfConfigs.guid);
						});
					}
					//P2OB-12186 Start
					let channelAttribute = devConfigToUpdate.getAttribute("channel");
					let partnerAttribute = devConfigToUpdate.getAttribute("partner");
					let partnerNameAttribute = devConfigToUpdate.getAttribute("PartnerName");
					
					if (partnerAccount != undefined && partnerAccount != "" && (devConfigToUpdate.attributes.partner.value === "" || devConfigToUpdate.attributes.partner.value === undefined)) {
						if (devConfigToUpdate.attributes.partner.value === "" && oldValue == "") { //added condition related P2OB-13106 
							updatePartnerChannelValueMap.set(devConfigToUpdate.guid, [{
								name: channelAttribute.name,
								value: "Indirect",
								displayValue: "Indirect",
								showInUi: true,
								readOnly: false
							}, {
								name: partnerAttribute.name,
								value: partnerAccountId,
								displayValue: partnerAccountName,
								lookup: partnerAccountId,
								showInUi: true,
								readOnly: false
							}, {
								name: partnerNameAttribute.name,
								value: partnerAccountName,
								displayValue: partnerAccountName

							}]);
						}
					}
					if ((partnerAccount === undefined || partnerAccount === "") && devConfigToUpdate.attributes.partner.value === "") {
						updatePartnerChannelValueMap.set(devConfigToUpdate.guid, [{
							name: channelAttribute.name,
							value: "Direct",
							displayValue: "Direct",
							showInUi: true,
							readOnly: false
						}, {
							name: partnerAttribute.name,
							value: "",
							displayValue: "",
							showInUi: true,
							readOnly: true
						}]);

					}
					if (devConfigToUpdate.attributes.channel.value === "Direct") {
						updatePartnerChannelValueMap.set(devConfigToUpdate.guid, [{
							name: channelAttribute.name,
							value: "Direct",
							displayValue: "Direct",
							showInUi: true,
							readOnly: false
						},
						{
							name: partnerAttribute.name,
							value: "",
							displayValue: "",
							showInUi: true,
							readOnly: true,
							required: false
						}]);
					}
					if (devConfigToUpdate.attributes.channel.value === "Indirect") {
						updatePartnerChannelValueMap.set(devConfigToUpdate.guid, [{
							name: channelAttribute.name,
							value: "Indirect",
							displayValue: "Indirect",
							showInUi: true,
							readOnly: false
						}, {
							name: partnerAttribute.name,
							value: partnerAttribute.value,
							lookup: partnerAttribute.value,
							showInUi: true,
							readOnly: false

						}]);
					}
					//P2OB-13497 Changes Start
					if (devConfigToUpdate.attributes.channel.value === "Indirect" && devConfigToUpdate.attributes.partner.value === "") {
						updatePartnerChannelValueMap.set(devConfigToUpdate.guid, [{
							name: partnerAttribute.name,
							showInUi: true,
							readOnly: false,
							required: true
						}]);
					} //P2OB-13497 Changes End
					if (updatePartnerChannelValueMap) {
						updatePartnerChannelValueMap.forEach(async (v, k) => {
							await stdProdComp.updateConfigurationAttribute(k, v, true);
						});
					} //P2OB-12186 End
					//changes related to P2OB-11856 Start
					let attribute = devConfigToUpdate.getAttribute("domain_sc");
					
					if (devConfigToUpdate.attributes.domain_sc.value == "" && oldValue != newValue && oldValue != "" && doUpdate === true) {
						if (devConfigToUpdate.attributes.product_sc.value != "") {
							let productAttribute = devConfigToUpdate.getAttribute("product_sc").name;
							resetLookupMap.set(devConfigToUpdate.guid, [{
								name: productAttribute,
								value: '',
								displayValue: ''
							}]);
						}
					} //changes related to P2OB-11856 End
					//Changes Start P2OB-12127
					let productAttributeValue = devConfigToUpdate.getAttribute("product_sc").value;
					let srmAttribute = devConfigToUpdate.getAttribute("SRM").name;
					let descriptionAttribute = devConfigToUpdate.getAttribute("ProductDescription").name;
					let productcodeAttribute = devConfigToUpdate.getAttribute("ProductCode").name;
					let gmarpctattribute = devConfigToUpdate.getAttribute("GrossMargin_Pct").name;
					let RenRevattribute = devConfigToUpdate.getAttribute("renewalrevenue").name;
					let RCRevattribute = devConfigToUpdate.getAttribute("rc").name;
					let productStrAttribute = devConfigToUpdate.getAttribute("productString").name;

					if (productAttributeValue === "") {
						resetProductDependedAttributeMap.set(devConfigToUpdate.guid, [{
							name: srmAttribute,
							value: '',
							displayValue: ''
						}, {
							name: descriptionAttribute,
							value: '',
							displayValue: ''
						}, {
							name: productcodeAttribute,
							value: '',
							displayValue: ''
						}, {
							name: gmarpctattribute,
							value: '',
							displayValue: ''

						}, {
							name: RenRevattribute,
							value: '',
							displayValue: ''
						}, {
							name: RCRevattribute,
							value: '',
							displayValue: ''
						}, {
							name: productStrAttribute,
							value: '',
							displayValue: ''
						}]);
					} //Changes End P2OB-12127
					if (resetLookupMap) {
						resetLookupMap.forEach(async (v, k) => {
							await stdProdComp.updateConfigurationAttribute(k, v, true);
						});
					}
					if (resetProductDependedAttributeMap && productAttributeValue == "") {
						resetProductDependedAttributeMap.forEach(async (v, k) => {
							await stdProdComp.updateConfigurationAttribute(k, v, true);
						});
					}
					//P2OB-12668 start
					if (devConfigToUpdate.attributes.quantity.value != "") {
						let qtyattribute = devConfigToUpdate.getAttribute("quantity");
						let qtyattributeval = devConfigToUpdate.attributes.quantity.value;
						qtyattributeval = Math.round(qtyattributeval);
						updateMap.set(devConfigToUpdate.guid, [{
							name: qtyattribute.name,
							value: qtyattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (devConfigToUpdate.attributes.contractterms.value != "") {
						let cnttermattribute = devConfigToUpdate.getAttribute("contractterms");
						let cnttermattributeval = devConfigToUpdate.attributes.contractterms.value;
						cnttermattributeval = Math.round(cnttermattributeval);
						updateMap.set(devConfigToUpdate.guid, [{
							name: cnttermattribute.name,
							value: cnttermattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					} //P2OB-12668 End
					//Changes Start P2OB-12638
					if (devConfigToUpdate.attributes.oc.value != "") {
						let ocattribute = devConfigToUpdate.getAttribute("oc");
						let ocattributeval = devConfigToUpdate.attributes.oc.value;
						ocattributeval = (Number(ocattributeval)).toFixed(2);
						updateMap.set(devConfigToUpdate.guid, [{
							name: ocattribute.name,
							value: ocattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (devConfigToUpdate.attributes.rc.value != "") {
						let rcattribute = devConfigToUpdate.getAttribute("rc");
						let rcattributeval = devConfigToUpdate.attributes.rc.value;
						rcattributeval = (Number(rcattributeval)).toFixed(2);
						updateMap.set(devConfigToUpdate.guid, [{
							name: rcattribute.name,
							value: rcattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (devConfigToUpdate.attributes.renewalrevenue.value != "") {
						let rrattribute = devConfigToUpdate.getAttribute("renewalrevenue");
						let rrattributeval = devConfigToUpdate.attributes.renewalrevenue.value;
						rrattributeval = (Number(rrattributeval)).toFixed(2);
						updateMap.set(devConfigToUpdate.guid, [{
							name: rrattribute.name,
							value: rrattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (devConfigToUpdate.attributes.techtransrevenue.value != "") {
						let ttattribute = devConfigToUpdate.getAttribute("techtransrevenue");
						let ttattributeval = devConfigToUpdate.attributes.techtransrevenue.value;
						ttattributeval = (Number(ttattributeval)).toFixed(2);
						updateMap.set(devConfigToUpdate.guid, [{
							name: ttattribute.name,
							value: ttattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					//DIGI - 7020 -Gokul
                    if (devConfigToUpdate.attributes.grossmargin_pct.value != "") {
                        let grosspercentattribute = devConfigToUpdate.getAttribute("grossmargin_pct");
                        let grosspercentattributeval = devConfigToUpdate.attributes.grossmargin_pct.value;
                        grosspercentattributeval = (Number(grosspercentattributeval)).toFixed(2);                    
                        updateGrossMarginMap.set(devConfigToUpdate.guid, [{
                            name: grosspercentattribute.name,
                            value: grosspercentattributeval,
                            showInUi: true,
                            readOnly: false
                        }]);
                        if (updateGrossMarginMap) {
                            updateGrossMarginMap.forEach(async (v, k) => {
                                await stdProdComp.updateConfigurationAttribute(k, v, true);
                            });
                        }
                    }
                    if (devConfigToUpdate.attributes.totalcost.value != "" && devConfigToUpdate.attributes.totalcost.value != null) {
                        let totcostattribute = devConfigToUpdate.getAttribute("totalcost");
						let totcostattributeval = devConfigToUpdate.attributes.totalcost.value;
						totcostattributeval = (Number(totcostattributeval)).toFixed(2);
						updateMap.set(devConfigToUpdate.guid, [{
							name: totcostattribute.name,
							value: totcostattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (devConfigToUpdate.attributes.previousannuityrevenue.value != "") {
						let prevattribute = devConfigToUpdate.getAttribute("previousannuityrevenue");
						let prevattributeval = devConfigToUpdate.attributes.previousannuityrevenue.value;
						prevattributeval = (Number(prevattributeval)).toFixed(2);
						updateMap.set(devConfigToUpdate.guid, [{
							name: prevattribute.name,
							value: prevattributeval,
							showInUi: true,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					if (devConfigToUpdate.attributes.combinedrecurringcharges.value != "") {
						let ccattribute = devConfigToUpdate.getAttribute("combinedrecurringcharges");
						let ccattributeval = devConfigToUpdate.attributes.combinedrecurringcharges.value;
						ccattributeval = (Number(ccattributeval)).toFixed(2);
						updateMap.set(devConfigToUpdate.guid, [{
							name: ccattribute.name,
							value: ccattributeval,
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					} //Changes End P2OB-12638
					//Changes Start P2OB-12473
					//Commented by Aman Soni for P2OB-12565/13501 || Start
					/*let GMVisattributeval = devConfigToUpdate.getAttribute("Gross Margin").value;
					GMVisattributeval = (Number(GMVisattributeval)).toFixed(2);
					
					if (GMVisattributeval != 0 || GMVisattributeval != 0.00) {
						let GMpctattribute = devConfigToUpdate.getAttribute("GrossMargin_Pct");
						let revaddval = (Number(devConfigToUpdate.attributes.oc.value)) + (Number(devConfigToUpdate.attributes.rc.value)) + (Number(devConfigToUpdate.attributes.renewalrevenue.value)) + (Number(devConfigToUpdate.attributes.acquisitionrevenue.value));
						revaddval = (Number(revaddval)).toFixed(2);
						let GMpctattributeval = 100 * GMVisattributeval;
						
						if (revaddval != 0 || revaddval != 0.00) {
							GMpctattributeval = GMpctattributeval / revaddval;
							GMpctattributeval = (Number(GMpctattributeval)).toFixed(2);
							updateMap.set(devConfigToUpdate.guid, [{
								name: GMpctattribute.name,
								value: GMpctattributeval,
								showInUi: true,
								readOnly: false
							}]);
							
							if (updateMap) {
								updateMap.forEach(async (v, k) => {
									await stdProdComp.updateConfigurationAttribute(k, v, true);
								});
							}
						}
					}*/ //Commented by Aman Soni for P2OB-12565/13501 || End
					//Changes End P2OB-12473
					if (devConfigToUpdate.attributes.competitor.value === "") {
						let ccattribute = devConfigToUpdate.getAttribute("competitor");
						updateMap.set(devConfigToUpdate.guid, [{
							name: ccattribute.name,
							value: "NO COMPETITOR",
							readOnly: false
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}
					/* Changes for P2OB-12535 start
					let gmattribute = devConfigToUpdate.getAttribute("GrossMargin");
					
					if (gmattribute.name === "GrossMargin" && gmattribute.value != "" && gmattribute.value != null) {
						let GMattribute = devConfigToUpdate.getAttribute("GrossMargin");
						let GMattributeval = GMattribute.value;
						GMattributeval = (Number(GMattributeval)).toFixed(2);
						console.log("GrossMargin", GMattributeval);
						updateMap.set(devConfigToUpdate.guid, [{
							name: GMattribute.name,
							value: GMattributeval,
							showInUi: true,
							readOnly: false
						}]);
						console.log('updateMap***',updateMap);
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					}*/
					//P2OB-12497 changes start
					let prdDescAttribute = devConfigToUpdate.getAttribute("PrdDesc");
					
					if (prdDescAttribute.name === "PrdDesc") {
						let productDescriptionAttribute = devConfigToUpdate.getAttribute("ProductDescription");
						
						if (productDescriptionAttribute.value === "" && !isProductDescriptionToUpdateToNull) {
							let prdDescAttributeVal = prdDescAttribute.value;
							console.log("Product Description", prdDescAttributeVal);
							updateMap.set(devConfigToUpdate.guid, [{
								name: productDescriptionAttribute.name,
								value: prdDescAttributeVal,
								showInUi: true,
								readOnly: false
							}]);
						} else if(productDescriptionAttribute.value === "" && isProductDescriptionToUpdateToNull) {
							updateMap.set(devConfigToUpdate.guid, [{
								name: productDescriptionAttribute.name,
								value: '',
								showInUi: true,
								readOnly: false
							}]);
						}
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					} //P2OB-12497 changes end
					//P2OB-13156 changes start
					let site = devConfigToUpdate.getAttribute("Site");
					let currentBasket = await CS.SM.getActiveBasket();
					var JSONNode = {};
					
					if (site != null && site != undefined && site.value != null && site.value != undefined && site.value != '') {
						let adborId = devConfigToUpdate.getAttribute("AdborId");
						let LocId = devConfigToUpdate.getAttribute("LOCId");
						let installationAddressAttribute = devConfigToUpdate.getAttribute("InstallationAddress");
						var siteLookupRecord = await currentBasket.getLookupValues(stdProdComp.id, "Site_Lookup", {
							"AccountId": accountId
						});
						var result = siteLookupRecord['result'];
						
						if (result != null && result != undefined) {
							for (i = 0; i < result.length; i++) {
								if (site.value === result[i].Id) {
									JSONNode = result[i];
								}
							}
						}
						if (siteLookupRecord != null && siteLookupRecord != undefined) {
							updateMap.set(devConfigToUpdate.guid, [{
								name: adborId.name,
								value: JSONNode.AdborID__c
							}, {
								name: LocId.name,
								value: JSONNode.NBN_Location_ID__c
							}, {
								name: installationAddressAttribute.name,
								value: JSONNode.Installation_Address__c
							}]);
							
							if (updateMap) {
								updateMap.forEach(async (v, k) => {
									await stdProdComp.updateConfigurationAttribute(k, v, true);
								});
							}
						}
					} else if (site != null && site != undefined && (site.value === null || site.value === undefined || site.value === '')) {
						let adborId = devConfigToUpdate.getAttribute("AdborId");
						let LocId = devConfigToUpdate.getAttribute("LOCId");
						let installationAddressAttribute = devConfigToUpdate.getAttribute("InstallationAddress");
						updateMap.set(devConfigToUpdate.guid, [{
							name: adborId.name,
							value: ''
						}, {
							name: LocId.name,
							value: ''
						}, {
							name: installationAddressAttribute.name,
							value: 'Other Products and Services (Site Agnostic)'
						}]);
						
						if (updateMap) {
							updateMap.forEach(async (v, k) => {
								await stdProdComp.updateConfigurationAttribute(k, v, true);
							});
						}
					} //P2OB-13156 changes end//P2OB-13156 changes end 
					//P2OB-13549 changes start
					let domainLookupAttribute = devConfigToUpdate.getAttribute("domain_sc");
					let productLookupValue = devConfigToUpdate.getAttribute("product_sc");
					let srvList = devConfigToUpdate.getAttribute("srvListString").value;
					let productString = devConfigToUpdate.getAttribute("productString").value;
					let domainStringAttribute = devConfigToUpdate.getAttribute("domainString");
					var DomainNode = {};
					
					if (productLookupValue != null && productLookupValue != undefined && productLookupValue.value != null && productLookupValue.value != undefined && productLookupValue.value != '' && isProductChanged) {
						const filterJsonString = "{\r\n" + "\"srvListString\": \"" + srvList + "\",\r\n" + "\"productString\": \"" + productString + "\"\r\n" + "}";
						const paramObj = JSON.parse(filterJsonString);
						var domainLookupRecord = await currentBasket.getLookupValues(stdProdComp.id, "LC_Domain", paramObj);
						var result = domainLookupRecord['result'];
						
						if (result != null && result != undefined) {
							for (i = 0; i < result.length; i++) {
								DomainNode = result[i];
							}
						}
						if (domainLookupRecord != null && domainLookupRecord != undefined) {
							updateMap.set(devConfigToUpdate.guid, [{
								name: domainLookupAttribute.name,
								value: DomainNode.domain__c,
								lookup: DomainNode.domain__c

							}, {
								name: domainStringAttribute.name,
								value: DomainNode.domain__c
							}]);
							
							if (updateMap) {
								updateMap.forEach(async (v, k) => {
									await stdProdComp.updateConfigurationAttribute(k, v, true);
								});
							}
						}
					} //P2OB-13549 changes end
				});
			}
		}
	} catch (error) {
		console.log('[CurrProdCat_UI] afterAttributeUpdated() exception: ' + error);
		return false;
	}
	return true;
};

AN_UI.afterSave = async function() {
	try {
		//changes start P2OB-13106
		let solution = await CS.SM.getActiveSolution();
		let stdProdComp = solution.getComponentBySchemaName(AN_COMPONENTS.StandardProduct);
		let config = Object.values(solution.getConfigurations())[0];
		let updatePartnerValueMap = new Map();

		if (solution.name === 'Standard Product Solution') {
			if (stdProdComp.schema && stdProdComp.schema.configurations && Object.values(stdProdComp.schema.configurations).length > 0) {
				Object.values(stdProdComp.schema.configurations).forEach(async (devConfigToUpdate) => {
					let channelAttribute = devConfigToUpdate.getAttribute("channel");
					let partnerAttribute = devConfigToUpdate.getAttribute("partner");
					
					if (devConfigToUpdate.attributes.channel.value === "Direct") {
						updatePartnerValueMap.set(devConfigToUpdate.guid, [{
							name: channelAttribute.name,
							value: "Direct",
							displayValue: "Direct",
							showInUi: true,
							readOnly: false
						}, {
							name: partnerAttribute.name,
							value: "",
							displayValue: "",
							showInUi: true,
							readOnly: true,
							required: false
						}]);
					}
					/* changes start _ INC000097601288 */
					if (devConfigToUpdate.attributes.productcategoryvalue.value === "Purple" && devConfigToUpdate.getAttribute("GrossMargin_Pct").value === '') {
                         updatePartnerValueMap.set(devConfigToUpdate.guid, [{
                             name: 'GrossMargin_Pct',
                             required: true
                         }]);
                         devConfigToUpdate.status = false;
                         devConfigToUpdate.statusMessage = 'Please enter GrossMargin(%)';
                    } /* changes End _ INC000097601288 */
					if (updatePartnerValueMap) {
						updatePartnerValueMap.forEach(async (v, k) => {
							await stdProdComp.updateConfigurationAttribute(k, v, true);
						});
					}
				});
			}
		}
		//changes End P2OB-13106
		let currentSolution = await CS.SM.getActiveSolution();
		let currentBasket = await CS.SM.getActiveBasket();
		let inputMap = {};
		inputMap["updateBAUSolutionTotals"] = currentSolution.id;
		//no need to wait for result
		AN_IO.afterSave(inputMap);
	} catch (error) {
		console.log('[CurrProdCat_UI] afterSave() exception: ' + error);
	}
};