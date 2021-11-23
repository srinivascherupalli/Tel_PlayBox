/*
Author: Ankit Goswami
Jira : EDGE:140755, EDGE-137466, EDGE-142924
1. Shubhi 			4/10/2020 		EDGE-137466 	oe rules  
2. Ankit  			11/05/2020 		EDGE-147597 	Resolve Dats issue for old bulk functionlity
3. Laxmi  27/05/2020 EDGE-147799 Bulk OE changes for port out reversal
4. Ankit Goswami 10/06/2020  INC000093064228 Remove today dates check
5. Laxmi Rahate  26/06/2020  EDGE-154371 - Added UI display message for Call Restrition Drop Down
6. Arinjay Singh	02-July-2020	EDGE 155244		JSPlugin Upgrade
7. Sandhya 09-Sep-2020 //EDGE-172941 INC000093743308 Fix
8. Manuga Kale :-08/17/2020 :- EDGE-165299 Update Label Names on Call restriction drop down
9. Shweta 	3-10-2020    Refactored
10.Sandhya   05/10/2020 // INC000093907636 Fix
11.Manish Berad     08/18/2020      EDGE-165632      Automate CRD Date for mobiles on Order Enrichment screen for CMP
12.Sandhya		10/11/2020	INC000094015239 Fix 	Bulk Enrichment UI Experience
13.Akanksha Jain	23/10/2020 		EDGE-174218		 To displya alert in case number reservation is not done on click of bulk enrichment
14.Kamlesh Kumar    18/1/2021       EDGE-191955      Added validation message for Bulk orderenrichment
Description :  Js for order enrichment rules for UI (new Java script)
*/
var deliveryDetailsHtmlNew = "";
var deliveryDetailsAddressHtmlNew = "";
var deliveryDetailsContactHtmlNew = "";
var crdHtmlNew = "";
var mfHtmlNew = "";
var persistentValuesNew = {};
var allOeValuesNew = {};
var bulkOEComponentNameNew;
var OESchemaIdMapNew = [];
var OEConfigurationsNew = [];
var OEAddressSearchResultNew = [];
var OEAddressSearchPhraseNew;
var OETimeoutAddressSearchNew;
var OEContactSearchResultNew = [];
var OEContactSearchPhraseNew;
var OETimeoutContactSearchNew;
var OETimeoutNoDataNew;
var isReadOnlyModeNew = false;
var isMacdOrederNew = false;
var OEStartXNew;
var OEColumnWidthNew;
var OEColumnToResizeNew;
var isPreviousSelectionCompleteNew = true;
var oeGuidMap = new Map();
var oeIdList = [];
var retMapOE = {};

const tooltipElementNew = '<div class="tooltip icon-info" id="help"  style="position:absolute; top:-3px; right:-20px;">' + '<span class="tooltip-arrow"></span>' + '<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' + "</div>";
async function BulkcreateOELogic(solutionName, componentName) {
	bulkOEComponentNameNew = componentName;
	isPreviousSelectionCompleteNew = true;
	deliveryDetailsHtmlNew = "";
	deliveryDetailsAddressHtmlNew = "";
	deliveryDetailsContactHtmlNew = "";
	crdHtmlNew = "";
	mfHtml = "";
	OESchemaIdMapNew = [];
	OEConfigurationsNew = [];
	OEAddressSearchPhraseNew = "";
	OEContactSearchPhraseNew = "";
	OEAddressSearchResultNew = [];
	OEContactSearchResultNew = [];
	persistentValuesNew = {};
	allOeValuesNew = {};
	oeGuidMap = new Map();
	await BulkUtils.populateSchemaIds();
	await BulkUtils.getProdNumber(); //EDGE-172941 INC000093743308 Fix
	await BulkUtils.fetchConfigurations();
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
		'<span class="icon-close" onclick="BulkUtils.closeOe()" />' +
		"</div>" +
		"</div>" +
		"</h2>" +
		"</div>" +
		'</BR><div id="errorPannel" class="slds-theme_error"></div></BR>';
	table +=
		'<div class="slds-col slds-size_3-of-3" id="main-nav-div-1">' +
		'<div class="slds-path">' +
		'  <ul class="slds-path__nav" role="listbox">' +
		'    <li class="slds-path__item slds-is-error slds-is-active slds-size_1-of-3" id="OEtab_1"  title="Delivery Details" role="presentation" onclick="BulkUtils.setActive(this)">' +
		'      <a class="slds-path__link " href="javascript:void(0);" role="option" tabindex="0" aria-selected="true" aria-controls="oe-tab-default-1" name="Delivery details" id="oe-tab-default-1__item"><span class="slds-path__stage"><div class="slds-icon slds-icon_x-small icon-warning" id="oe-tab-delivery__item"></div></span><span> Delivery Details</span></a>' +
		"    </li>" +
		'    <li class="slds-path__item slds-is-error slds-size_1-of-3"  title="Customer Requested Dates" role="presentation"  id="OEtab_2" onclick="BulkUtils.setActive(this)">' +
		'      <a class="slds-path__link " href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-2" name="Customer requested Dates" id="oe-tab-default-2__item"> <span class="slds-path__stage"><div class="slds-icon slds-icon_x-small icon-warning"   id="oe-tab-CRD__item"></div></span><span>Customer Requested Dates</span></a>' +
		"    </li>" +
		'    <li class="slds-path__item slds-is-complete slds-size_1-of-3" title="Features" role="presentation"  id="OEtab_3" onclick="BulkUtils.setActive(this)">' +
		'      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-3" name="Mobility features" id="oe-tab-default-3__item"><span class="slds-path__stage"><div class="slds-icon slds-icon_x-small icon-check" id="oe-tab-Features__item"></div></span><span>Features</span></a>' +
		"    </li>" +
		"  </ul>" +
		"</div>" +
		"</div>" +
		'<div class="modal-header slds-modal__header">' +
		"</div>";
	table +=
		'<div class="slds-grid slds-gutters" style="margin-block-end: -.75rem;height: 60%;">' + //INC000094015239 Fix Bulk Enrichment UI Experience
		'<span class="slds-spinner_container" style="display: none; position:absolute; top:350px" id="main-save-spinner-1">' +
		'<div role="status" class="slds-spinner slds-spinner slds-spinner_large slds-spinner_brand">' +
		'<span class="slds-assistive-text">Saving</span>' +
		'<div class="slds-spinner__dot-a"></div>' +
		'<div class="slds-spinner__dot-b"></div>' +
		"</div>" +
		"</span>" +
		'<div class="slds-col slds-size_3-of-6" onmousemove="BulkUtils.handlemousemove(event)" onmouseup="BulkUtils.handlemouseup(event)" style="height:100%;" >' + //INC000094015239 Fix Bulk Enrichment UI Experience
		'<div class="slds-grid slds-gutters" style="margin-bottom: 10px">' +
		'<div class="slds-col ">' +
		'<input class="slds-input" type="text" placeholder="Search..." id="configurationSearch" attName="configurationSearch" value=""' +
		'  onkeyup="BulkUtils.configurationSearchKeyUp(event)" /> ' +
		"</div>" +
		"</div>" +
		'<div class="slds-table_header-fixed_container slds-border_top slds-border_bottom slds-border_right slds-border_left " style="overflow-y: scroll;height:100%;">' + //INC000094015239 Fix Bulk Enrichment UI Experience
		'<div id="tableViewInnerDiv" style="height:100%;">' +
		'<table aria-multiselectable="true" role="grid" class="slds-table slds-table_header-fixed  slds-table_bordered  slds-table_fixed-layout slds-table_resizable-cols">' +
		"<thead>" +
		'<tr class="">';
	table +=
		'<th   scope="col" style="width:32px">' +
		'<span id="column-group-header" class="slds-assistive-text">Choose a row</span>' +
		'<div class="slds-th__action slds-th__action_form slds-align_absolute-center slds-cell-fixed">' +
		'<div class="slds-checkbox ">' +
		'<input type="checkbox" class="pc-selection_all" name="options" id="checkboxAll" value="checkboxAll" tabindex="-1" aria-labelledby="check-select-all-label column-group-header"  onclick="BulkUtils.updateSelectAll(' +
		"'" +
		"Yes" +
		"'" +
		')" />' +
		'<label class="slds-checkbox__label" for="checkboxAll" id="check-select-all-label">' +
		'<span class="slds-checkbox_faux"></span>' +
		'  <span class="slds-form-element__label slds-assistive-text">Select All</span>' +
		"</label>" +
		"</div>" +
		"</div>" +
		"</th>";
	table +=
		' <th aria-label="Name" aria-sort="none" class="slds-is-resizable dv-dynamic-width"  style="text-align:center; width: 350px" scope="col">' +
		' <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center dv-dynamic-width" style="width: 350px">' +
		'   <span class="slds-truncate">&nbsp;&nbsp;&nbsp;Name</span>' +
		'<div class="slds-resizable">' +
		'<span class="slds-resizable__handle" onmousedown="BulkUtils.handlemousedown(event)">' +
		'<span class="slds-resizable__divider"></span>' +
		"</span>" +
		"</div>" +
		"</div>" +
		" </th>";
	table += ' <th aria-label="Model" aria-sort="none" class="slds-is-resizable" style="text-align:center; width: 60px" scope="col">' + '    <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center slds-align_absolute-center">Enriched</div>' + "  </th>";
	table += "</tr>" + "</thead>" + '<tbody id="config_table_scrollable_container">';
	table += BulkUtils.createConfigTableRows("", "DeliveryTab");
	table += BulkUtils.createConfigTableRows("", "CRDTab");
	table += BulkUtils.createConfigTableRows("", "FeatureTab"); 
	table += "</tbody>" + "</table>" + "</div>" + "</div></div>";
	table += //INC000094015239 Fix Bulk Enrichment UI Experience
		' <div class="slds-col slds-size_1-of-2 slds-scrollable" style="overflow-y: auto;" ><div id="oe-tab-default-1" class="slds-tabs_default__content slds-show" role="tabpanel" aria-labelledby="oe-tab-default-1__item"><div id="delivery_oe"></div></div>' +
		'<div id="oe-tab-default-2" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-2__item"><div id="crd_oe"></div></div>' +
		'<div id="oe-tab-default-3" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-3__item"><div id="features_oe"></div></div></div></div>';


	table += '<div><div style="margin-top: 10px;  margin-bottom: 10px">' + '<button class="slds-button slds-button_neutral slds-float_right"  onclick="BulkUtils.closeOe()">Cancel</button>' + '<button class="slds-button slds-button_neutral slds-float_right" onclick="BulkUtils.saveOEForSelectedConfigs(false)">Save</button>' + "</div></div>";
	let container = document.getElementsByClassName("container");
	container[0].innerHTML = table.trim();
	container[0].style.padding = "15px";
	container[0].style.height = "100%"; //INC000094015239 Fix Bulk Enrichment UI Experience
	let tableValuePopulateNew = BulkUtils.isOredrEnrichmentDoneForConfigurationStatus(OEConfigurationsNew);
	if (tableValuePopulateNew) BulkUtils.prepareDeliveryDetails();
	if (!tableValuePopulateNew) {
		["delivery_oe", "features_oe", "crd_oe"].forEach((el) => BulkUtils.drawNoupdateRequiredDetails(el));


		let detabdeCancel = document.getElementById("OEtab_1");
		let iconForbeforCRDcancel = document.getElementById("OEtab_2");
		iconForbeforCRDcancel.classList.remove("slds-is-error");
		iconForbeforCRDcancel.classList.add("slds-is-complete");
		detabdeCancel.classList.remove("slds-is-error");
		detabdeCancel.classList.add("slds-is-complete");
		let detabdeCancelTab = document.getElementById("oe-tab-delivery__item");
		let iconForbeforCRDcancelTab = document.getElementById("oe-tab-CRD__item");
		detabdeCancelTab.classList.remove("icon-warning");
		detabdeCancelTab.classList.add("icon-check");
		iconForbeforCRDcancelTab.classList.remove("icon-warning");
		iconForbeforCRDcancelTab.classList.add("icon-check");
	}
	if (tableValuePopulateNew) {
		crdHtmlNew = await BulkUtils.prepareOETable("Customer requested Dates");
		mfHtmlNew = await BulkUtils.prepareOETable("Mobility features");
		document.getElementById("oe-tab-default-3__item").click();
		document.getElementById("oe-tab-default-2__item").click();
		document.getElementById("oe-tab-default-1__item").click();
		BulkUtils.tabForDeliveryDetails();
		BulkUtils.TabForCRD();
	}
	return Promise.resolve(true);
}
var BulkUtils = {
	populateSchemaIds: async function () {
		OESchemaIdMapNew = {};
		let solution = await CS.SM.getActiveSolution();
		if (solution.components) {
			let component = solution.getComponentByName(bulkOEComponentNameNew);
			if (component && component.orderEnrichments) {
				Object.values(component.orderEnrichments).forEach((oe) => (OESchemaIdMapNew[oe.name] = oe.id));
			}
		}
		return Promise.resolve(true);
	},
	fetchConfigurations: async function () {
		OEConfigurationsNew = [];
		let solution = await CS.SM.getActiveSolution();
		//let currentBasket = await CS.SM.getActiveBasket();
		if (solution.components && Object.values(solution.components).length > 0) {
			let component = solution.getComponentByName(bulkOEComponentNameNew);
			let cmpConfig = await component.getConfigurations();
			let showNumberReservationErr ; // EDGE-174218 akanksha added

			if (component && cmpConfig && Object.values(cmpConfig).length > 0) {
				Object.values(cmpConfig).forEach(function (config) {
					showNumberReservationErr = "FALSE"; // EDGE-174218 akanksha added
					let disconnectionDateAttribute = Object.values(config.attributes).find((a) => a.name === "DisconnectionDate");
					let ActiveConfig = config.disabled;
					if ((!disconnectionDateAttribute || !disconnectionDateAttribute.showInUi) && !ActiveConfig) {
						let row = {};
						row.guid = config.guid;
						let name = "";
						if (bulkOEComponentName === "Mobility") {
							row.name = BulkUtils.getNameCwpMobility(config, config.name);
							row.modelName = BulkUtils.getModelNameCWP(config);
						} else {
							row.name = BulkUtils.getNameEM(solution, config, config.name, retMapOE[config.id]); //EDGE-172941 INC000093743308 Fix
							//row.name = BulkUtils.getNameEM(solution, config, config.name);
							row.modelName = BulkUtils.getModelNameEM(config);
							row.CustomerFacingServiceId = BulkUtils.getModelAttributeForEM(config, "CustomerFacingServiceId", false);
							row.SiteDeliveryContact = BulkUtils.getModelAttributeForEM(config, "SiteDeliveryContact", false);
							row.SiteDeliveryAddress = BulkUtils.getModelAttributeForEM(config, "SiteDeliveryAddress", false);
							row.NotBeforeCRD = BulkUtils.getModelAttributeForEM(config, "Not Before CRD", false);
							row.PreferredCRD = BulkUtils.getModelAttributeForEM(config, "Preferred CRD", false);
							row.Notes = BulkUtils.getModelAttributeForEM(config, "Notes", false);
							row.CallRestriction = BulkUtils.getModelAttributeForEM(config, "Call Restriction", false);
							row.INTROAM = BulkUtils.getModelAttributeForEM(config, "INTROAM", false);
							row.isDeliveryDetailsRequired = BulkUtils.getModelAttributeForEM(config, "isDeliveryDetailsRequired", false);
							row.isCRDDatesRequired = BulkUtils.getModelAttributeForEM(config, "isCRDDatesRequired", false);
							row.isFeaturesRequired = BulkUtils.getModelAttributeForEM(config, "isFeaturesRequired", false);
							row.isDeliveryEnrichmentNeededAtt = BulkUtils.getModelAttributeForEM(config, "isDeliveryEnrichmentNeededAtt", false);
							row.isCRDEnrichmentNeededAtt = BulkUtils.getModelAttributeForEM(config, "isCRDEnrichmentNeededAtt", false);
							//EDGE-174218 akanksha adding starts
							row.isSIMAvailbilityType = BulkUtils.getModelAttributeForEM(config, "SimAvailabilityType", false);
                            				if(row.isSIMAvailbilityType ==="" || row.isSIMAvailbilityType === undefined)
								showNumberReservationErr = "TRUE";
							//EDGE-174218 akanksha  adding ends

							if (row.SiteDeliveryContact && row.SiteDeliveryAddress && (!row.isDeliveryEnrichmentNeededAtt || row.isDeliveryEnrichmentNeededAtt === "false")) row.IsDeliveryDetailsEnriched = true;
							else row.IsDeliveryDetailsEnriched = false;
							//Added below check for EDGE-142321
							if ((row.isDeliveryEnrichmentNeededAtt === "false" || !row.isDeliveryEnrichmentNeededAtt) && (row.isDeliveryDetailsRequired === "false" || !row.isDeliveryDetailsRequired)) {
								row.IsDeliveryDetailsEnriched = true;
							}
							// End 142321
							if (row.NotBeforeCRD && row.PreferredCRD) row.IsCRdEnriched = true;
							else row.IsCRdEnriched = false;
						}


						row.searchField = row.name + " " + row.modelName + "" + row.CustomerFacingServiceId;
						row.orderEnrichmentList = config.orderEnrichmentList;
						OEConfigurationsNew.push(row);
					}
				});
				//EDGE-174218 akanksha  adding starts
				if(showNumberReservationErr !=="" && showNumberReservationErr ==="TRUE")
				{
					CS.SM.displayMessage('Please complete Number Enrichment before proceeding to Order Enrichment');
				}
				//EDGE-174218 akanksha  adding ends
			}
		}
		return Promise.resolve(true);
	},
	getModelAttributeForEM(config, attr, flag) {
		let attrValue = "";
		let attrName = Object.values(config.attributes).find((a) => a.name === attr);
		if (!attrName || attrName.length === 0) return attrValue;
		if (!flag) attrValue = attrName.value;
		else {
			attrValue = attrName.displayValue;
		}
		return attrValue;
	},
	getNameCwpMobility: function (config, defaultName) {
		let mobilityaName = defaultName;
		let mpAtt = Object.values(config.attributes).find((attr) => attr.name === "MobilityPlan" && attr.displayValue);
		if (mpAtt) {
			mobilityaName = mpAtt.displayValue;
		}
		return mobilityaName;
	},
	getModelNameCWP: function (config) {
		let modelName = "";
		if (config.relatedProductList && config.relatedProductList.length > 0) {
			config.relatedProductList.find((relatedConfig) => {
				if (relatedConfig.name === "Mobile Device" && relatedConfig.type === "Related Component") {
					if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
						var modelAtt = Object.values(relatedConfig.configuration.attributes).find((a) => a.name === "MobileHandsetModel" && a.displayValue);
					}
					if (modelAtt) {
						if (modelName.length > 0) modelName += ", ";
						modelName = modelName + modelAtt.displayValue;
					}
				}
			});
		}
		if (!modelName) return "-";
		return modelName;
	},
	getNameEM: function (solution, config, defaultName, oeNumber) {
		//EDGE-172941 INC000093743308 Fix - Added oeNumber parameter)
		let name = defaultName;
		if (!solution.schema.configurations || Object.values(solution.schema.configurations).length === 0) return name;
		let cmpConfig = Object.values(solution.schema.configurations)[0];
		let offerType = Object.values(cmpConfig.attributes).find((a) => a.name === "OfferType");
		if (!offerType) return name;
		name = offerType.displayValue;
		let planType = Object.values(config.attributes).find((a) => a.name === "SelectPlanType");
		if (planType) name = name + " - " + planType.displayValue;
		let plan = Object.values(config.attributes).find((a) => a.name === "Select Plan");
		if (plan) name = name + " - " + plan.displayValue;
		//EDGE-172941 INC000093743308 Fix Start
		if((config && config.id !='' && config.id !=undefined && config.id !=null) &&(oeNumber && oeNumber!='' && oeNumber !=undefined && oeNumber !=null)){ // INC000093907636 Fix
			name = name + "-" + oeNumber;
		}
		//EDGE-172941 INC000093743308 Fix End
		return name;
	},
	getModelNameEM: function (config) {
		let modelName = "";
		if (config.relatedProductList && config.relatedProductList.length > 0) {
			config.relatedProductList.find((relatedConfig) => {
				if (relatedConfig.name === "Device" && relatedConfig.type === "Related Component") {
					if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {
						var modelAtt = Object.values(relatedConfig.configuration.attributes).find((a) => {
							return a.name === "MobileHandsetModel" && a.displayValue;
						});
						var ChangeTypeDeviceAttr = Object.values(relatedConfig.configuration.attributes).find((a) => {
							return a.name === "ChangeTypeDevice";
						});
					}
					if (modelAtt && modelAtt.length > 0 && ChangeTypeDeviceAttr.value !== "PayOut" && ChangeTypeDeviceAttr.value !== "PaidOut") {
						if (modelName.length > 0) modelName += ", ";
						modelName = modelName + modelAtt.displayValue;
					}
				}
			});
		}
		if (!modelName) return "-";
		return modelName;
	},
	closeOe: function () {
		var el = document.getElementsByClassName("cdk-overlay-backdrop cdk-overlay-dark-backdrop cdk-overlay-backdrop-showing");
		if (el) {
			for (let i = 0; i < el.length; i++) {
				el[i].click();
			}
		}
	},
	setActive: function (elem) {
		BulkUtils.persistValuesForCurrentTab();


		if (elem.title === "Delivery Details") {
			BulkUtils.updateSelectAll("No");
			BulkUtils.showOnlyDeliveryConfiguration();
		} else if (elem.title === "Customer Requested Dates") {
			BulkUtils.updateSelectAll("No");
			BulkUtils.showOnlyCRDConfiguration();
		} else if (elem.title === "Features") {
			BulkUtils.updateSelectAll("No");
			BulkUtils.showOnlyFeatureConfiguration();
		}
		document.getElementById("errorPannel").innerHTML = "";
		let mainDiv = document.getElementById("main-nav-div-1");
		let tabs = mainDiv.getElementsByClassName("slds-path__item");
		for (let i = 0; i < tabs.length; i++) {
			tabs[i].classList.remove("slds-is-active");
		}
		let links = mainDiv.getElementsByClassName("slds-path__link");
		for (let i = 0; i < links.length; i++) {
			links[i].setAttribute("aria-selected", false);
			links[i].setAttribute("tabindex", "-1");
			let tabId = links[i].getAttribute("aria-controls");
			if (tabId) {
				document.getElementById(tabId).classList.add("slds-hide");
				document.getElementById(tabId).classList.remove("slds-show");
			}
		}
		elem.classList.add("slds-is-active");
		elem.getElementsByClassName("slds-path__link")[0].setAttribute("aria-selected", true);
		elem.getElementsByClassName("slds-path__link")[0].setAttribute("tabindex", "0");

		let tabId = elem.getElementsByClassName("slds-path__link")[0].getAttribute("aria-controls");
		document.getElementById(tabId).classList.add("slds-show");
		document.getElementById(tabId).classList.remove("slds-hide");
		let tableValuePopulateActive = BulkUtils.isOredrEnrichmentDoneForConfigurationStatus(OEConfigurationsNew);
		if (tableValuePopulateActive) {
			BulkUtils.drawOETabs();
		}


		if (isReadOnlyModeNew) BulkUtils.setControlsAsReadonly();
	},
	handlemousemove: function (e) {
		if (OEStartXNew && OEColumnToResizeNew) {
			let width = OEColumnWidthNew + e.screenX - OEStartXNew;
			if (width > 50) {
				OEColumnToResizeNew.forEach((c) => {
					c.style.width = width + "px";
				});
			}
		}
	},
	handlemouseup: function (e) {
		OEStartXNew = undefined;
		OEColumnToResizeNew = undefined;
	},
	configurationSearchKeyUp: async function (event) {
		let element = document.getElementById("configurationSearch");
		if (element) {
			if (event.key === "Enter" || !element.value || element.value.length === 0 || (element.value && element.value.length >= 3)) {
				let container = document.getElementById("config_table_scrollable_container");
				container.innerHTML = await BulkUtils.createConfigTableRows(element.value);
			}
		}
		return Promise.resolve(true);
	},
	updateSelectAll: function (flag) {
		let SelctionVar = "";
		let selectAll;
		let isActiveTab = document.getElementsByClassName("slds-is-active");
		let tesxva = isActiveTab[3].innerText;
		let isEnaableConfig = document.getElementsByClassName("slds-hint-parent slds-hide"); //EDGE-147597 added by ankit


		if (tesxva === "Delivery Details") {
			SelctionVar = "DeliveryTab";
		} else if (tesxva === "Customer Requested Dates") {
			SelctionVar = "CRDTab";
		} else if (tesxva === "Features") {
			SelctionVar = "FeatureTab";
		}
		let selections = document.getElementsByClassName("pc-selection");
		selectAll = document.getElementById("checkboxAll");


		if (flag === "Yes") {
			selectAll = document.getElementById("checkboxAll");
		} else if (flag === "No") {
			selectAll = document.getElementById("checkboxAll");
			selectAll.checked = false;
		}


		for (let i = 0; i < selections.length; i++) {
			//EDGE-147597 added by ankit || start
			let IsSelect = true;
			for (let x = 0; x < isEnaableConfig.length; x++) {
				let guidConfig = isEnaableConfig[x].getAttribute("data-value");
				if (selections[i].defaultValue === guidConfig && isEnaableConfig[x].id.includes(SelctionVar)) {
					IsSelect = false;
				}
			}
			//EDGE-147597 added by ankit || End
			if (selections[i].id.includes(SelctionVar) && IsSelect) {
				//EDGE-147597 added by ankit IsSelect
				selections[i].checked = selectAll.checked;
				let row = Utils.getClosestParent(selections[i], "tr");
				if (selections[i].checked) {
					row.classList.add("slds-is-selected");
					row.setAttribute("aria-selected", true);
				} else {
					row.classList.remove("slds-is-selected");
					row.setAttribute("aria-selected", false);
				}
			}
		}
	},
	handlemousedown: function (e) {
		OEColumnToResizeNew = document.querySelectorAll("table thead .dv-dynamic-width");
		if (OEColumnToResizeNew && OEColumnToResizeNew.length > 0) {
			OEStartXNew = e.screenX;
			OEColumnWidthNew = parseInt(OEColumnToResizeNew[0].style.width, 10);
		}
	},
	createConfigTableRows: function (filterPhrase, tabName) {
		let table = "";

		for (let i = 0; i < OEConfigurationsNew.length; i++) {
			let row = OEConfigurationsNew[i];
			if (filterPhrase && !row.searchField.toLowerCase().includes(filterPhrase.toLowerCase())) continue;
			table += '<tr  class="slds-hint-parent" id="Check_Details_' + tabName + i + '"' + 'onclick="BulkUtils.onConfigurationClick(event, this,' + "'" + tabName + "'" + ')" data-value="' + row.guid + '">';
			if (!isReadOnlyModeNew) {
				table +=
					'<td style="width:30px" class="slds-text-align_left" role="gridcell">' +
					'    <div class="slds-checkbox slds-align_absolute-center" >\n' +
					'       <input type="checkbox" class="pc-selection" name="options" id="checkbox-' +
					tabName +
					"-" +
					row.guid +
					'" value="' +
					row.guid +
					'" tabindex="0" aria-labelledby="' +
					row.guid +
					' column-group-header" onclick="BulkUtils.markSelection(event, this)"/>\n' +
					'       <label class="slds-checkbox__label" for="checkbox-' +
					tabName +
					"-" +
					row.guid +
					'" id="' +
					row.guid +
					"-" +
					tabName +
					'">\n' +
					'          <span class="slds-checkbox_faux"></span>\n' +
					'          <span class="slds-form-element__label slds-assistive-text">Select item' +
					row.name +
					"</span>\n" +
					"       </label>\n" +
					"    </div>" +
					"</td>";
			}
			if (row.CustomerFacingServiceId) {
				table += '<td  class="slds-text-align_left slds-truncate" role="gridcell">' + '<div class="slds-truncate" title="' + row.name + '">' + row.name + "-" + row.CustomerFacingServiceId + "<br/>" + row.modelName;
				+"</div>" + "</td>";
			} else {
				table += '<td  class="slds-text-align_left slds-truncate" role="gridcell">' + '<div class="slds-truncate" title="' + row.name + '">' + row.name + "<br/>" + row.modelName;
				+"</div>" + "</td>";
			}
			if (!isReadOnlyModeNew) {
				let oeDone = BulkUtils.isOredrEnrichmentDoneForConfiguration(row.orderEnrichmentList);
				table += '<td  class="slds-text-align_center" role="gridcell">';
				//spinner
				table += '<span class="slds-spinner_container" style="display: none" id="row-loading-' + tabName + "-" + row.guid + '">' + '<div role="status" class="slds-spinner slds-spinner_small slds-spinner_brand">' + '<div class="slds-spinner__dot-a"></div>' + '<div class="slds-spinner__dot-b"></div>' + "</div>" + "</span>";
				//ticked icon for enriched row
				if (tabName === "DeliveryTab") {
					table += '    <span class="icon-check"   id="row-enriched-DeliveryTab-' + row.guid + '"';
					if (!row.IsDeliveryDetailsEnriched) {
						table += ' style="display: none" >';
					}
					table += "</span>";
					// warning info icon foe not enriched rows
					table += '<span class="icon-warning"  id="row-not-enriched-DeliveryTab-' + row.guid + '"';
					if (row.IsDeliveryDetailsEnriched) {
						table += ' style="display: none" >';
					} else {
						table += ' style="color: red" >';
					}
					table += "</span>";
				}
				if (tabName === "CRDTab") {
					table += '    <span class="icon-check"   id="row-enriched-CRDTab-' + row.guid + '"';
					if (!row.IsCRdEnriched) {
						table += ' style="display: none" >';
					}
					table += "</span>";
					// warning info icon foe not enriched rows
					table += '<span class="icon-warning"  id="row-not-enriched-CRDTab-' + row.guid + '"';
					if (row.IsCRdEnriched) {
						table += ' style="display: none" >';
					} else {
						table += ' style="color: red" >';
					}
					table += "</span>";
				}
				if (tabName === "FeatureTab") {
					table += '    <span class="icon-check"   id="row-enriched-FeatureTab-' + row.guid + '"';
					table += "</span>";
				}
				+"</td>";
			}
			table += "</tr>";
		}
		return table;
	},


	saveOEForSelectedConfigs: async function (closAfterSave) {
		try {
			let solution = await CS.SM.getActiveSolution();
			let spinner = document.getElementById("main-save-spinner-1");
			spinner.style.display = "block";


			let attributeMap;
			let selectedConfigs;
			let selectedConfigTabName;
			let isValid = false;
			let isCheckForDelTab = false;
			let isCheckForCRDTab = false;
			let isCheckForBothTab = false;
			BulkUtils.persistValuesForCurrentTab();

            selectedConfigs = BulkUtils.getSelectedConfigurations();
			selectedConfigTabName = BulkUtils.getSelectedConfigurationsTabName();
			if (selectedConfigTabName) {
				let tabNameGuid = Object.keys(selectedConfigTabName);
				for (let i = 0; i < tabNameGuid.length; i++) {
					if (tabNameGuid[i].includes("DeliveryTab")) {
						isCheckForDelTab = true;
					} else if (tabNameGuid[i].includes("CRDTab")) {
						isCheckForCRDTab = true;
					}
					// Added by laxmi EDGE-147799 || start
					else if (tabNameGuid[i].includes("FeatureTab")) {
						isValid = true;
					}
					// Added by laxmi EDGE-147799 || End
				}
			}
			if (isCheckForDelTab && isCheckForCRDTab) {
				isValid = await BulkUtils.validateData("BothDetails");
			} else if (isCheckForDelTab && !isCheckForCRDTab) {
				isValid = await BulkUtils.validateData("Delivery details");
			} else if (!isCheckForDelTab && isCheckForCRDTab) {
				isValid = await BulkUtils.validateData("Customer requested Dates");
			}


			if (solution.components && isValid) {
				let comp = solution.getComponentByName(bulkOEComponentNameNew);
				if (comp && comp.orderEnrichments) {
					Object.values(comp.orderEnrichments).forEach(function (oe) {
						OESchemaIdMapNew[oe.name] = oe.id;
					});
				}


				for (let k = 0; k < Object.values(comp.schema.configurations).length; k++) {
					let config = Object.values(comp.schema.configurations)[k];
					if (selectedConfigs.contains(config.guid)) {
						let oldList = [];
						Object.keys(allOeValuesNew).forEach((key) => {
							attributeMap = allOeValuesNew[key];
							if (config.orderEnrichmentList) {
								config.orderEnrichmentList.forEach((oe) => {
									let shouldDelete = true;
									if (attributeMap && attributeMap.length > 0) {
										for (let key in attributeMap[0]) {
											let a = Object.values(oe.attributes).find((at) => {
												return at.name === key;
											});
											if (!a || a.length === 0) shouldDelete = false;
										}
									}
									if (shouldDelete) oldList.push(oe.guid);
								});
							}
						});
						for (let h = 0; h < oldList.length; h++) {
							await comp.deleteOrderEnrichmentConfiguration(config.guid, oldList[h], true);
						}
					}
				}
			}


			let attrvalue = [];
			let updateTabMapForDel = {};
			let updateTabMapForCust = {};
			let currentBasket = await CS.SM.getActiveBasket();
			for (let i = 0; i < Object.values(OEConfigurationsNew).length; i++) {
				let row = OEConfigurationsNew[i];
				//EDGE-147597 added by ankit || start
				if (row.isDeliveryEnrichmentNeededAtt === "false" || row.isDeliveryEnrichmentNeededAtt === false) {
					updateTabMapForDel[row.guid] = [];
					let attrs = {};
					let parsedData1Intial = row.SiteDeliveryContact;
					let parsedData1;
					if (parsedData1Intial != null && parsedData1Intial != "") {
						if (parsedData1Intial) {
							let input = {};

							input["basketId"] = currentBasket.basketId;
							input["searchString"] = parsedData1Intial;
							input["option"] = "contact";
							await currentBasket.performRemoteAction("GetDeliveryDetailsLookupValues", input).then(function (values) {
								if (values.contact && values.contact.length) {
									parsedData1 = JSON.stringify(values.contact[0]);
								}
							});
						}
						if (parsedData1) {
							let parsedDataDel = JSON.parse(parsedData1);
							attrs["DeliveryContact"] = parsedData1Intial ? parsedData1Intial : "";
							attrs["Name"] = parsedDataDel.Name ? parsedDataDel.Name : "";
							attrs["FirstName"] = parsedDataDel.FirstName ? parsedDataDel.FirstName : "";
							attrs["LastName"] = parsedDataDel.LastName ? parsedDataDel.LastName : "";
							attrs["Phone"] = parsedDataDel.Phone ? parsedDataDel.Phone : "";
							attrs["Mobile"] = parsedDataDel.MobilePhone ? parsedDataDel.MobilePhone : "";
							attrs["Email"] = parsedDataDel.Email ? parsedDataDel.Email : "";
							attrs["IsDeliveryDetailsEnriched"] = attrs["DeliveryContact"] && attrs["DeliveryAddress"] ? true : false;
						}
					}


					let parsedDataIntial2 = row.SiteDeliveryAddress;
					let parsedData2;
					if (parsedDataIntial2 != null && parsedDataIntial2 != "") {
						if (parsedDataIntial2) {
							let input = {};
							input["basketId"] = currentBasket.basketId;
							input["searchString"] = parsedDataIntial2;
							input["option"] = "addresses";
							await currentBasket.performRemoteAction("GetDeliveryDetailsLookupValues", input).then(function (values) {
								if (values.addresses && values.addresses.length) {
									parsedData2 = JSON.stringify(values.addresses[0]);
								}
							});
						}
						if (parsedData2) {
							var parsedDataAdd = JSON.parse(parsedData2);
							attrs["DeliveryAddress"] = parsedDataIntial2 ? parsedDataIntial2 : "";
							attrs["ADBOIRId"] = parsedDataAdd.ADBOIRId ? parsedDataAdd.ADBOIRId : "";
							attrs["Postcode"] = parsedDataAdd.Postcode ? parsedDataAdd.Postcode : "";
							attrs["Street"] = parsedDataAdd.Street ? parsedDataAdd.Street : "";
							attrs["Address"] = parsedDataAdd.Address ? parsedDataAdd.Address : "";
							attrs["IsDeliveryDetailsEnriched"] = attrs["DeliveryContact"] && attrs["DeliveryAddress"] ? true : false;
						}
					}
					updateTabMapForDel[row.guid].push(attrs);
				}
				if (row.isCRDEnrichmentNeededAtt === "false" || row.isCRDEnrichmentNeededAtt === false) {
					updateTabMapForCust[row.guid] = [];
					let attrscud = {};
					attrscud["Not Before CRD"] = row.NotBeforeCRD ? row.NotBeforeCRD : "";
					attrscud["Preferred CRD"] = row.PreferredCRD ? row.PreferredCRD : "";
					attrscud["Notes"] = row.Notes ? row.Notes : "";
					updateTabMapForCust[row.guid].push(attrscud);
				}
				//EDGE-147597 added by ankit || End
			}


			attributeMap = {};
			updateTabMap = {};
			if (selectedConfigTabName && isValid) {
				let tabNameGuid = Object.keys(selectedConfigTabName);
				for (let i = 0; i < tabNameGuid.length; i++) {
					let oeDataKeys = Object.keys(allOeValuesNew);
					if (!updateTabMap[selectedConfigTabName[tabNameGuid[i]]]) {
						updateTabMap[selectedConfigTabName[tabNameGuid[i]]] = [];
						for (let l = 0; l < oeDataKeys.length; l++) {
							let key1 = oeDataKeys[l];
							attributeMap = allOeValuesNew[key1];
							if (updateTabMapForDel[selectedConfigTabName[tabNameGuid[i]]] && key1 === "Delivery details" && !attributeMap[0]["DeliveryAddress"] && !attributeMap[0]["DeliveryContact"]) {
								attributeMap = updateTabMapForDel[selectedConfigTabName[tabNameGuid[i]]];
							}
							//EDGE-147597 added by ankit || start
							else if (updateTabMapForCust[selectedConfigTabName[tabNameGuid[i]]] && key1 === "Customer requested Dates" && !attributeMap[0]["Not Before CRD"] && !attributeMap[0]["Preferred CRD"]) {
								attributeMap = updateTabMapForCust[selectedConfigTabName[tabNameGuid[i]]];
							}
							//EDGE-147597 added by ankit || End


							// Arinjay Singh 15 July 2020 Start
							let desiredComponent;
							if (solution.components && Object.values(solution.components).length > 0) {
								for (let comp of Object.values(solution.components)) {
									if (comp.orderEnrichments) {
										for (let oeSchema of Object.values(comp.orderEnrichments)) {
											if (oeSchema.name.includes(key1)) {
												desiredComponent = oeSchema;
											}
										}
									}
								}
							}


							let attributeMap1 = allOeValuesNew[key1][0];
							let aData = [];
							for (let attrName in attributeMap1) {
								aData.push({ name: attrName, value: { value: attributeMap1[attrName], displayValue: attributeMap1[attrName] } });
							}
							let component = solution.findComponentsByConfiguration(selectedConfigTabName[tabNameGuid[i]]);
							let oeConfiguration = desiredComponent.createConfiguration(aData);
							await component.addOrderEnrichmentConfiguration(selectedConfigTabName[tabNameGuid[i]], oeConfiguration, false);


							// Arinjay Singh 15 July 2020 End
							validateOERules.MandateOESchemaOnAccepted(); // Added by laxmi EDGE-147799
						}
					}
					for (let l = 0; l < oeDataKeys.length; l++) {
						let key1 = oeDataKeys[l];
						attributeMap = allOeValuesNew[key1];


						if (attributeMap[0]["DeliveryAddress"] && attributeMap[0]["DeliveryContact"] && tabNameGuid[i].includes("DeliveryTab")) {
							BulkUtils.markConfigurationEnrichmentStatus(selectedConfigTabName[tabNameGuid[i]], true, "DeliveryTab");
						} else if (attributeMap[0]["Not Before CRD"] && attributeMap[0]["Preferred CRD"] && tabNameGuid[i].includes("CRDTab")) {
							BulkUtils.markConfigurationEnrichmentStatus(selectedConfigTabName[tabNameGuid[i]], true, "CRDTab");
						}
					}
				}


				await BulkUtils.pushDataToParentConfigs(selectedConfigs, selectedConfigTabName);
				//await BulkUtils.pushDataToOrderEnrichmentConfigs(selectedConfigs);
				CS.SM.displayMessage("Selected configurations updated successfully!", "success");
				if (closAfterSave) {
					BulkUtils.closeOe();
				} else {
					await BulkUtils.fetchConfigurations();
					BulkUtils.tabForDeliveryDetails();
					BulkUtils.TabForCRD();
				}
			} else {
				if (!isValid) CS.SM.displayMessage("Configuration is not saved!", "error");
				else CS.SM.displayMessage("Select Mobility subscription(s)!", "info");
			}
			spinner.style.display = "none";
			return Promise.resolve(true);
		} catch (e) {
			return Promise.resolve(true);
		}
	},
	isOredrEnrichmentDoneForConfigurationStatus: function (OEConfigurationsList) {
		if (OEConfigurationsList.length > 0) return true;
		else return false;


		//return isStatus;
	},
	prepareDeliveryDetails: function () {
		BulkUtils.createDeliveryAddressObjects();
		BulkUtils.createDeliveryContactObjects();
		BulkUtils.drawDeliveryDetails("delivery_oe");
	},


	drawNoupdateRequiredDetails: function (oeId) {
		deliveryDetailsHtmlNew = "No Update Required";
		let el = document.getElementById(oeId);
		if (el) el.innerHTML = deliveryDetailsHtmlNew.trim();
	},

	prepareOETable: async function (oeName) {
		let grid = "";
		let CheckFlag=true;
		let oe = await BulkUtils.getOEAttributes(oeName);
		if (oe) {
			Object.values(oe.schema.attributes).forEach(function (attr) {
				if (attr.showInUi) {
					let helpIconId;
					if (attr.type === "String") {
						grid += "<div>";
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' + "<span>" + attr.label + "</span>";
						if (attr.required && !isReadOnlyModeNew) {
							grid += tooltipElementNew;
						}
						grid += "</label>" + '<div class="slds-form-element__control">' + '<textarea class="inpt" type="text" attName="' + attr.name + '"' + 'class="slds-input">' + attr.value + "</textarea>" + "</div>" + "</div>";
						grid += "</div>";
					} else if (attr.type === "Boolean") {
						grid += "<div><strong>You may choose to modify these features</strong></div>";
						grid += "<div>";
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' + "<span>" + attr.label + "</span>";
						if (attr.required && !isReadOnlyModeNew) {
							grid += tooltipElementNew;
						}
						grid += "</label>" + '<div class="slds-form-element__control">' + '<input attName="' + attr.name + '" class="inpt" type="checkbox" id="checkbox-' + attr.name + '" value="' + attr.value + '"' + 'class="slds-input"/>' + "</div>" + "</div>";
						grid += "</div>";
					} else if (attr.type === "Date") {
						if (CheckFlag) {
							CheckFlag = false;
							grid += "<div><strong>Request for delivery or installation</strong></div>";
						}
						grid += "<div>";
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' + "<span>" + attr.label + "</span>";


						if (attr.required && !isReadOnlyModeNew) {
							helpIconId = "help-" + attr.name;
							grid += '<div class="tooltip icon-info" id="' + helpIconId + '"  style="position:absolute; top:-3px; right:-20px;">' + '<span class="tooltip-arrow"></span>' + '<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' + "</div>";
						}


						grid += "</label>" + '<div class="slds-form-element__control">' + '<input  attName="' + attr.name + '" class="inpt" type="date" value="' + attr.value + '" id="input-' + attr.name + '"';
						if (attr.required) {
							grid += " onchange=\"BulkUtils.validateControl(this , '" + helpIconId + "')\"  ";
						}


						grid += 'class="slds-input" />';
						grid += "</div>";
						if (helpIconId === "help-Not Before CRD") {
							grid += "<div>Customer will not be ready before this date for delivery or installation</div>";
						}
						if (helpIconId === "help-Preferred CRD") {
							grid += "<div>Customer" + "'" + "s preferred date of delivery or installation</div>";
						}
						grid += "</div>";
						grid += "</div>";
					} else if (attr.type === "Picklist") {
						var value = attr.value;
						grid += "<div>";
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' + "<span>" + attr.label + "</span>";


						if (attr.required && !isReadOnlyModeNew) {
							grid += tooltipElementNew;
						}
						grid += "</label>" + '<div class="slds-form-element__control">' + '<select attName="' + attr.name + '" class="inpt-select" class="slds-select" data-id="' + attr.name + '">';
						for (var j = 0; j < attr.options.length; j++) {
							// Manuga Kale EDGE-165299     Update Label Names on Call restriction drop down
							if (attr.options[j].value == value) {
								grid += '<option value="' + attr.options[j].value + '" selected>' + attr.options[j].label + "</option>";
							} else {
								grid += '<option value="' + attr.options[j].value + '">' + attr.options[j].label + "</option>";
							}
						}
						grid += "</select>" + "</div>" + "  Call restrictions do not apply to data plans.</div>"; //EDGE-154371 Changes
						grid += "</div>";
					}
				}
			});
			//});
		}


		return Promise.resolve(grid.trim());
	},
	tabForDeliveryDetails: function () {
		let isDeliveryStatus = false;
		for (let x = 0; x < OEConfigurationsNew.length; x++) {
			if (!OEConfigurationsNew[x].IsDeliveryDetailsEnriched) {
				isDeliveryStatus = true;
			}
		}
		let detabdel3 = document.getElementById("OEtab_1");
		let detabdel4 = document.getElementById("oe-tab-delivery__item");
		if (!isDeliveryStatus) {
			detabdel3.classList.remove("slds-is-error");
			detabdel3.classList.add("slds-is-complete");
			detabdel4.classList.remove("icon-warning");
			detabdel4.classList.add("icon-check");
		} else {
			detabdel3.classList.remove("slds-is-complete");
			detabdel3.classList.add("slds-is-error");
			detabdel4.classList.remove("icon-check");
			detabdel4.classList.add("icon-warning");
		}
	},
	TabForCRD: function () {
		let isCRDStatus = false;
		for (let x = 0; x < OEConfigurationsNew.length; x++) {
			if (!OEConfigurationsNew[x].IsCRdEnriched) {
				isCRDStatus = true;
			}
		}


		let iconForbeforCRDStatus = document.getElementById("oe-tab-CRD__item");
		let iconForPreferedCRDStatus = document.getElementById("OEtab_2");
		if (!isCRDStatus) {
			iconForbeforCRDStatus.classList.remove("icon-warning");
			iconForbeforCRDStatus.classList.add("icon-check");
			iconForPreferedCRDStatus.classList.remove("slds-is-error");
			iconForPreferedCRDStatus.classList.add("slds-is-complete");
		} else {
			iconForbeforCRDStatus.classList.remove("icon-check");
			iconForbeforCRDStatus.classList.add("icon-warning");
			iconForPreferedCRDStatus.classList.remove("slds-is-complete");
			iconForPreferedCRDStatus.classList.add("slds-is-error");
		}
	},


	persistValuesForCurrentTab: async function () {
		if (isReadOnlyModeNew) return;
		let inputs = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt");
		let selects = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-select");
		let lookups = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-lookup");
		let i;
		let attName;


		// EDGE-165632 start 
		let todaysDate=Utils.formatDate((new Date()).setHours(0,0,0,0));
		let loadedSolution = await CS.SM.getActiveSolution();
		let isCMP=false;
		if (loadedSolution.componentType && loadedSolution.name.includes('Corporate Mobile Plus')) {
			isCMP=true;
		}
		// EDGE-165632 end


		for (let i = 0; i < inputs.length; i++) {
			let type = inputs[i].getAttribute("type");
			if (type && type === "checkbox") {
				persistentValuesNew[inputs[i].getAttribute("attName")] = inputs[i].checked;


				// EDGE-165632 start 
				}else if(type && type === 'date' && inputs[i].value===""){
				if(isCMP){
					persistentValuesNew[inputs[i].getAttribute('attName')] =todaysDate;
				}else{
					persistentValuesNew[inputs[i].getAttribute('attName')] =inputs[i].value;
				}
				// EDGE-165632  end


			} else {
				persistentValuesNew[inputs[i].getAttribute("attName")] = inputs[i].value;
			}
		}


		for (let i = 0; i < selects.length; i++) {
			attName = selects[i].getAttribute("attName");
			persistentValuesNew[attName] = selects[i].value;
		}


		for (let i = 0; i < lookups.length; i++) {
			attName = lookups[i].getAttribute("attName");
			persistentValuesNew[attName] = lookups[i].getAttribute("data-value");
		}


		let links = document.getElementsByClassName("slds-path__link");
		for (let i = 0; i < links.length; i++) {
			if (links[i].getAttribute("aria-selected") === "true") {
				allOeValuesNew[links[i].getAttribute("name")] = BulkUtils.getAttributeMap();
				break;
			}
		}
	},
	showOnlyDeliveryConfiguration: function () {
		for (let i = 0; i < OEConfigurationsNew.length; i++) { 
			let row = OEConfigurationsNew[i];
			let dev = document.getElementById("Check_Details_DeliveryTab" + i);
			let dev1 = document.getElementById("Check_Details_CRDTab" + i);
			let dev2 = document.getElementById("Check_Details_FeatureTab" + i);
			if (row.isDeliveryDetailsRequired === "true" || row.isDeliveryDetailsRequired === true) {
				dev.classList.remove("slds-hide");
			} else {
				dev.classList.add("slds-hide");
			}
			dev1.classList.add("slds-hide");
			dev2.classList.add("slds-hide");
		}
	},
	showOnlyCRDConfiguration: function () {
		for (let i = 0; i < OEConfigurationsNew.length; i++) {
			let row = OEConfigurationsNew[i];
			let dev = document.getElementById("Check_Details_DeliveryTab" + i);
			let dev1 = document.getElementById("Check_Details_CRDTab" + i);
			let dev2 = document.getElementById("Check_Details_FeatureTab" + i);
			if (row.isCRDDatesRequired === "true" || row.isCRDDatesRequired === true) {
				dev1.classList.remove("slds-hide");
			} else {
				dev1.classList.add("slds-hide");
			}
			dev.classList.add("slds-hide");
			dev2.classList.add("slds-hide");
		}
	},
	showOnlyFeatureConfiguration: function () {
		for (let i = 0; i < OEConfigurationsNew.length; i++) {
			let row = OEConfigurationsNew[i];
			let dev = document.getElementById("Check_Details_DeliveryTab" + i);
			let dev1 = document.getElementById("Check_Details_CRDTab" + i);
			let dev2 = document.getElementById("Check_Details_FeatureTab" + i);
			if (row.isFeaturesRequired === "true" || row.isFeaturesRequired === true) {
				dev2.classList.remove("slds-hide");
			} else {
				dev2.classList.add("slds-hide");
			}
			dev.classList.add("slds-hide");
			dev1.classList.add("slds-hide");
		}
	},
	drawOETabs: function () {
		BulkUtils.drawOETable(crdHtmlNew, "crd_oe");
		BulkUtils.drawDeliveryDetails("delivery_oe");
		BulkUtils.drawOETable(mfHtmlNew, "features_oe");
	},
	setControlsAsReadonly: function () {
		let inputs = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt");
		let selects = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-select");
		let lookups = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-lookup");
		let i;


		for (let i = 0; i < inputs.length; i++) {
			inputs[i].readOnly = true;
			inputs[i].disabled = true;
		}


		for (let i = 0; i < selects.length; i++) {
			selects[i].readOnly = true;
			selects[i].disabled = true;
		}


		for (let i = 0; i < lookups.length; i++) {
			lookups[i].readOnly = true;
			lookups[i].disabled = true;
		}
	},
	onConfigurationClick: async function (ev, row, tabName) {
		if (!isPreviousSelectionCompleteNew) return;
		if (ev.target.className.includes("checkbox")) return;
		isPreviousSelectionCompleteNew = false;
		//Aditya Fixes EDGE-130398
		if (basketStage == "Contract Accepted" || basketStage == "Enriched" || basketStage == "Submitted") {
			await BulkUtils.onConfigurationPreview(row, tabName);
			return Promise.resolve(true);
		}
		persistentValuesNew = {};
		let configId = row.getAttribute("data-value");
		if (!configId) return;
		let config = OEConfigurationsNew.find((e) => {
			return e.guid === configId;
		});
		if (!config || config.length === 0) return;
		if (!config.orderEnrichmentList) return;
		config.orderEnrichmentList.forEach((oe) => {
			if (oe.attributes) {
				Object.values(oe.attributes).forEach((a) => {
					if (a.type === "Boolean") {
						persistentValuesNew[a.name] = a.value === "Yes" ? true : false;
					} else if (a.type === "Date" && a.value) {
						persistentValuesNew[a.name] = Utils.formatDate(a.value);
					} else {
						persistentValuesNew[a.name] = a.displayValue;
					}
				});
			}
		});
		BulkUtils.restoreValuesForCurrentTab();
		let tabs = document.getElementsByClassName("slds-path__link");
		for (let i = 0; i < tabs.length; i++) {
			if (tabs[i].getAttribute("aria-selected") === "true" && tabs[i].id.includes("oe-tab-default-")) {
				tabs[i].click();
				break;
			}
		}
		isPreviousSelectionCompleteNew = true;
		return Promise.resolve(true);
	},
	markSelection: function (ev, el) {
		ev.stopPropagation();
		let row = Utils.getClosestParent(el, "tr");
		if (el.checked) {
			row.classList.add("slds-is-selected");
			row.setAttribute("aria-selected", true);
		} else {
			row.classList.remove("slds-is-selected");
			row.setAttribute("aria-selected", false);
		}
	},
	isOredrEnrichmentDoneForConfiguration: function (orderEnrichmentList) {
		if (!orderEnrichmentList) return false;
		let notEnriched = orderEnrichmentList.find((oe) => {
			let emptyAttribute = Object.values(oe.attributes).find((a) => {
				return a.required && !a.value;
			});
			return emptyAttribute && emptyAttribute.length > 0;
		});


		if (notEnriched && notEnriched.length > 0) return false;
		return true;
	},
	getSelectedConfigurations: function () {
		let selections = document.getElementsByClassName("pc-selection");
		let configIds = [];
		for (let i = 0; i < selections.length; i++) {
			if (selections[i].checked && !configIds.contains(selections[i].getAttribute("value"))) {
				configIds.push(selections[i].getAttribute("value"));
			}
		}


		return configIds;
	},
	getSelectedConfigurationsTabName: function () {
		let selections = document.getElementsByClassName("pc-selection");
		let tabName = {};
		for (let i = 0; i < selections.length; i++) {
			if (selections[i].checked) {
				tabName[selections[i].id] = selections[i].getAttribute("value");
			}
		}


		return tabName;
	},
	validateData: async function (tabName) {
		let currentBasket = await CS.SM.getActiveBasket();
		let errorPanel = document.getElementById("errorPannel");
		let selected = "";
		let errorMessages = [];


		//let links = Object.values(document.getElementsByClassName('slds-path__link')).filter((links) => links.getAttribute('name') && links.getAttribute('name').toLowerCase() === 'Delivery details'.toLowerCase() || links.getAttribute('name').toLowerCase() === 'Customer requested Dates'.toLowerCase());
		let links = Object.values(document.getElementsByClassName("slds-path__link")).filter((links) => links.getAttribute("name"));
		for (let i = 0; i < links.length; i++) {
			selected = links[i].getAttribute("name");
			let attributeMap = allOeValuesNew[selected];
			if (selected.toLowerCase() === "Delivery details".toLowerCase() && (selected.toLowerCase() === tabName.toLowerCase() || tabName.toLowerCase() === "BothDetails".toLowerCase())) {
				if (!attributeMap[0]["DeliveryContact"]) {
					errorMessages.push("Delivery contact is not selected");
				}
				if (!attributeMap[0]["Email"] || !attributeMap[0]["Phone"]) {
					errorMessages.push("Selected delivery contact does not have email id or phone number; Please update the contact details");
				}
				if (!attributeMap[0]["DeliveryAddress"]) {
					errorMessages.push("Delivery address is not selected");
				}
			} else if (selected.toLowerCase() === "Customer requested Dates".toLowerCase() && (selected.toLowerCase() === tabName.toLowerCase() || tabName.toLowerCase() === "BothDetails".toLowerCase())) {
				if (!attributeMap[0]["Not Before CRD"]) {
					errorMessages.push("Not Before CRD is not populated");
				} else {
					let crd = new Date(attributeMap[0]["Not Before CRD"]);
					let today = new Date();
					today.setHours(0, 0, 0, 0);
					crd.setHours(0, 0, 0, 0);
					if (crd < today) {
						//EDGE-165632 Update Error message text
						errorMessages.push('Not Before CRD can not be a past date.');
					}
					if (bulkOEComponentNameNew == "Mobility" || bulkOEComponentNameNew == "Mobile Subscription") {
						//EDGE-92626
						let InputMap = {};
						InputMap["NotBefCRD"] = crd;
						InputMap["basketId"] = currentBasket.basketId;
						if ((NotBefCRD = !null)) {
							await currentBasket.performRemoteAction("EnrichmentValidationRemoter", InputMap).then((result) => {
								if (result && result != undefined && result.validationCRD && result.validationCRD === true) {
									errorPanel.innerHTML += "Not Before CRD should be at least 15 days prior to the CA Expiry Date, please select a correct Not Before CRD or generate a new CA for customer sign off</BR>";
									errorMessages.push("Not Before CRD should be at least 15 days prior to the CA Expiry Date, please select a correct Not Before CRD or generate a new CA for customer sign off");
								}
							});
						}
					}
				}


				if (!attributeMap[0]["Preferred CRD"]) {
					errorMessages.push("Preferred CRD is not populated");
				} else {
					let ncrd = new Date(attributeMap[0]["Not Before CRD"]);
					let crd = new Date(attributeMap[0]["Preferred CRD"]);
					if (crd < ncrd) {
						errorMessages.push("Preferred CRD can not be set to date before Not Before CRD");
					}
				}
			}
			//}
		}
		errorPanel.innerHTML = "";
		if (errorMessages.length > 0) {
			errorMessages.forEach((msg) => {
				errorPanel.innerHTML += msg + "</BR>";
			});
			return Promise.resolve(false);
		}
		return Promise.resolve(true);
	},


	markConfigurationEnrichmentStatus: function (guid, isEnriched, tabName) {
		let notEnrichedIcon = document.getElementById("row-not-enriched-" + tabName + "-" + guid);
		let enrichedIcon = document.getElementById("row-enriched-" + tabName + "-" + guid);
		if (isEnriched) {
			enrichedIcon.style.display = "block";
			notEnrichedIcon.style.display = "none";
		} else {
			enrichedIcon.style.display = "none";
			notEnrichedIcon.style.display = "block";
		}
	},


	pushDataToParentConfigs: async function (selectedConfigs, selectedConfigTabName) {
		let currentSolution = await CS.SM.getActiveSolution();
		updateMap = {};
		let attMap = [];
		let attributeMap;
		Object.keys(allOeValuesNew).forEach((key) => {
			attributeMap = allOeValuesNew[key];
			Object.keys(attributeMap[0]).forEach((key1) => {
				attMap[key1] = attributeMap[0][key1];
			});
		});
		let tabNameGuid = Object.keys(selectedConfigTabName);
		for (let i = 0; i < tabNameGuid.length; i++) {
			if (!updateMap[selectedConfigTabName[tabNameGuid[i]]]) updateMap[selectedConfigTabName[tabNameGuid[i]]] = [];


			if (tabNameGuid[i].includes("DeliveryTab")) {
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
					{
						name: "isDeliveryEnrichmentNeededAtt",
						value: false
					},
					{
						name: "SiteDeliveryContact",
						value: attMap["DeliveryContact"],
						displayValue: attMap["DeliveryContact"]
					},
					{
						name: "SiteDeliveryAddress",
						value: attMap["DeliveryAddress"],
						displayValue: attMap["DeliveryAddress"]
					}
				);
			}
			if (tabNameGuid[i].includes("CRDTab")) {
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
					{
						name: "isCRDEnrichmentNeededAtt",
						value: false
					},
					{
						name: "Not Before CRD",
						value: attMap["Not Before CRD"],
						displayValue: attMap["Not Before CRD"]
					},
					{
						name: "Preferred CRD",
						value: attMap["Preferred CRD"],
						displayValue: attMap["Preferred CRD"]
					},
					{
						name: "Notes",
						value: attMap["Notes"],
						displayValue: attMap["Notes"]
					}
				);
			}


			updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
				{
					name: "Call Restriction",
					value: attMap["Call Restriction"],
					displayValue: attMap["Call Restriction"]
				},
				{
					name: "INTROAM",
					value: attMap["International Roaming"],
					displayValue: attMap["International Roaming"]
				}
			);
		}

		if(updateMap && Object.keys(updateMap).length > 0){
			let component = await currentSolution.getComponentByName(bulkOEComponentNameNew);
			let keys = Object.keys(updateMap);		
			let complock = component.commercialLock;
			if (complock) component.lock("Commercial", false);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                //EDGE - 191955 Adding validation message for bulk enrichment
                const varConfig = component.getConfiguration(keys[i]);
                varConfig.status = false;
                varConfig.statusMessage = "Click on Validate and Save to save your changes.";
                //END EDGE - 191955
			}
			if (complock) component.lock("Commercial", true);
		}
		return Promise.resolve(true);
	},
	createDeliveryAddressObjects: function (addresses) {
		deliveryDetailsAddressHtmlNew = "";
		deliveryDetailsAddressHtmlNew +=
			'<div class="slds-form-element">' +
			'<label class="slds-form-element__label" for="combobox-id-da-search-field">Delivery Address</label>' +
			'<div class="slds-form-element__control" >' +
			'<div class="slds-combobox_container">' +
			'<div class="slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click" id = "lookup-id-address-search" aria-expanded="false" aria-haspopup="listbox" role="combobox">' +
			'<div class="slds-combobox__form-element slds-is-relative" role="none">' +
			'<input type="text" class="inpt-lookup slds-input slds-combobox__input" id="combobox-id-da-search-field" attName="DeliveryAddress" data-value="" aria-autocomplete="list" aria-controls="combobox-id-da-search-field" autoComplete="off" role="textbox" placeholder="Search..."  onkeyup="BulkUtils.addressSearchKeyUp(event)"  onfocus="BulkUtils.doAddressSearch()"/>';


		if (!isReadOnlyModeNew) {
			deliveryDetailsAddressHtmlNew +=
				'<div class="tooltip icon-info ng-star-inserted" id="combobox-id-da-search-field-info" style="position:absolute; right: 10px;">' +
				'<span class="tooltip-arrow"></span>' +
				'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' +
				"</div>" +
				'<span class="icon-close slds-float_right" onclick="BulkUtils.clearSelectedAddress()" id="combobox-id-da-search-field-x" style="position:absolute; top:35%; right:10px; display: none"/>';
		}

		deliveryDetailsAddressHtmlNew += "</div>" + '<div id="listbox-id-address-search" class="slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid" role="listbox">';
		deliveryDetailsAddressHtmlNew += BulkUtils.getAddressLookupResultList(OEAddressSearchResultNew);
		deliveryDetailsAddressHtmlNew += "</div>" + "	</div>" + "  <div>Update Delivery Address if Applicable</div>" + "	</div>" + "	</div>" + "	</div>";
	},
	createDeliveryContactObjects: function (contact) {
		deliveryDetailsContactHtmlNew = "</br>";


		deliveryDetailsContactHtmlNew +=
			'<div class="slds-form-element">' +
			'<label class="slds-form-element__label" for="combobox-id-dc-search-field">Delivery Contact</label>' +
			'<div class="slds-form-element__control" >' +
			'<div class="slds-combobox_container">' +
			'<div class="slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click" id = "lookup-id-contact-search" aria-expanded="false" aria-haspopup="listbox" role="combobox">' +
			'<div class="slds-combobox__form-element slds-is-relative" role="none">' +
			'<input type="text" class="inpt-lookup slds-input slds-combobox__input" id="combobox-id-dc-search-field" attName="DeliveryContact" data-value="" aria-autocomplete="list" aria-controls="combobox-id-dc-search-field" autoComplete="off" role="textbox" placeholder="Search..."  onkeyup="BulkUtils.contactSearchKeyUp(event)"  onfocus="BulkUtils.doContactSearch()"/>';


		if (!isReadOnlyModeNew) {
			deliveryDetailsContactHtmlNew +=
				'<div class="tooltip icon-info" id="combobox-id-dc-search-field-info"  style="position:absolute; right: 10px;>' +
				'<span class="tooltip-arrow"></span>' +
				'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' +
				"</div>" +
				'<span class="icon-close " onclick="BulkUtils.clearSelectedContact()" id="combobox-id-dc-search-field-x" style="position:absolute; top:35%; right: 10px; display: none" />';
		}

		deliveryDetailsContactHtmlNew += "</div>" + '<div id="listbox-id-contact-search" class="slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid"  role="listbox">';
		deliveryDetailsContactHtmlNew += BulkUtils.getContactLookupResultList(OEContactSearchResultNew);
		deliveryDetailsContactHtmlNew += "</div>" + "	</div>" + "	<div>Update Delivery Contact if Applicable</div>" + "	</div>" + "	</div>" + "	</div>";
	},
	drawDeliveryDetails: function (oeId) {
		BulkUtils.persistValuesForCurrentTab();
		deliveryDetailsHtmlNew = deliveryDetailsAddressHtmlNew + deliveryDetailsContactHtmlNew;
		var el = document.getElementById(oeId);
		if (el) el.innerHTML = deliveryDetailsHtmlNew.trim();
		BulkUtils.restoreValuesForCurrentTab();
	},


	getOEAttributes: async function (oeName) {
		let solution = await CS.SM.getActiveSolution();
		var retVal;
		if (solution.components) {
			let component = solution.getComponentByName(bulkOEComponentNameNew);
			if (component.orderEnrichments) {
				let oe = Object.values(component.orderEnrichments).find((oe) => oe.name === oeName);


				retVal = oe;
			}
		}
		return Promise.resolve(retVal);
		//}
	},
	drawOETable: function (tableHtml, oeId) {
		document.getElementById(oeId).innerHTML = tableHtml;
		BulkUtils.restoreValuesForCurrentTab();
	},
	getAddressLookupResultList: function (records) {
		var control = "";
		if (records && records.length > 0) {
			control = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">';
			for (let j = 0; j < records.length; j++) {
				let val = JSON.stringify(records[j]);
				control +=
					'<li role="presentation" class="slds-listbox__item">' +
					'<div id="option-da-' +
					j +
					'" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" title="' +
					records[j].Name +
					'" role="option"  onclick="BulkUtils.selectDeliveryAddress(this)"' +
					"data-value='" +
					val +
					"'" +
					">" +
					'<span class="slds-media__body">' +
					'<span  class="slds-truncate">' +
					records[j].Address_ID__c +
					" | " +
					records[j].Name +
					" | " +
					records[j].Address_Status__c +
					"</span>" +
					"</span>" +
					"	</div>" +
					"</li>";
			}
			control += "</ul>";
		}
		return control;
	},


	clearSelectedAddress: function () {
		let ase = document.getElementById("combobox-id-da-search-field");
		ase.value = "";
		ase.setAttribute("data-value", "");
		ase.readOnly = false;
		document.getElementById("combobox-id-da-search-field-x").style.display = "none";
		document.getElementById("combobox-id-da-search-field-info").style.display = "block";
	},


	clearSelectedContact: function () {
		let ase = document.getElementById("combobox-id-dc-search-field");
		ase.value = "";
		ase.setAttribute("data-value", "");
		ase.readOnly = false;
		document.getElementById("combobox-id-dc-search-field-x").style.display = "none";
		document.getElementById("combobox-id-dc-search-field-info").style.display = "block";
	},


	getContactLookupResultList: function (records) {
		let control = "";
		if (records && records.length > 0) {
			control = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">';
			for (let j = 0; j < records.length; j++) {
				let val = JSON.stringify(records[j]);
				control +=
					'<li role="presentation" class="slds-listbox__item">' +
					'<div id="option-dc-' +
					j +
					'" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" title="' +
					records[j].Name +
					'" role="option" onclick="BulkUtils.selectContact(this)"' +
					"data-value='" +
					val +
					"'" +
					">" +
					'<span class="slds-media__body">' +
					'<span  class="slds-truncate" >' +
					records[j].Name;


				if (records[j].Email) {
					control += " | " + records[j].Email;
				} else {
					control += " | -";
				}


				if (records[j].Phone) {
					control += " | " + records[j].Phone;
				} else {
					control += " | -";
				}


				if (records[j].MobilePhone) {
					control += " | " + records[j].MobilePhone;
				} else {
					control += " | -";
				}


				control += "</span>" + "</span>" + "	</div>" + "</li>";
			}
			control += "</ul>";
		}
		return control;
	},


	restoreValuesForCurrentTab: function () {
		let inputs = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt");
		let selects = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-select");
		let lookups = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-lookup");
		//let i;
		let attName;
		let helpIconId;
		let info;

		for (let i = 0; i < inputs.length; i++) {
			let type = inputs[i].getAttribute("type");
			if (type && type === "checkbox") {
				if (persistentValuesNew[inputs[i].getAttribute("attName")] === undefined) {
					inputs[i].checked = true;
				} else {
					inputs[i].checked = persistentValuesNew[inputs[i].getAttribute("attName")];
				}
			} else {
				if (persistentValuesNew[inputs[i].getAttribute("attName")]) {
					inputs[i].value = persistentValuesNew[inputs[i].getAttribute("attName")];
				}
			}


			if (persistentValuesNew[inputs[i].getAttribute("attName")]) {
				helpIconId = "help-" + inputs[i].getAttribute("attName");
				info = document.getElementById(helpIconId);
				if (info) {
					info.style.display = "none";
				}
			}
		}


		for (let i = 0; i < selects.length; i++) {
			attName = selects[i].getAttribute("attName");
			if (persistentValuesNew[attName]) {
				selects[i].value = persistentValuesNew[attName];
			}


			if (persistentValuesNew[attName]) {
				helpIconId = "help-" + attName;
				info = document.getElementById(helpIconId);
				if (info) {
					info.style.display = "none";
				}
			}
		}


		for (let i = 0; i < lookups.length; i++) {
			attName = lookups[i].getAttribute("attName");
			if (persistentValuesNew[attName]) {
				lookups[i].setAttribute("data-value", persistentValuesNew[attName]);

				if (!isReadOnlyModeNew) {
					lookups[i].value = JSON.parse(persistentValuesNew[attName]).Name;
					let xButton = document.getElementById(lookups[i].id + "-x");
					lookups[i].readOnly = true;
					xButton.style.display = "block";
				} else {
					//Aditya Fixes EDGE-130398
					lookups[i].value = JSON.parse(persistentValuesNew[attName]).Name;
				}


				info = document.getElementById(lookups[i].id + "-info");
				if (info) {
					info.style.display = "none";
				}
			} else {
				lookups[i].setAttribute("data-value", "");
				lookups[i].value = "";


				if (!isReadOnlyModeNew) {
					let xButton = document.getElementById(lookups[i].id + "-x");
					lookups[i].readOnly = false;
					xButton.style.display = "none";
				}


				info = document.getElementById(lookups[i].id + "-info");
				if (info) {
					info.style.display = "block";
				}
			}
		}
	},


	selectDeliveryAddress: function (element) {
		let ase = document.getElementById("combobox-id-da-search-field");
		ase.value = element.title;
		ase = document.getElementById("combobox-id-da-search-field");
		ase.setAttribute("data-value", element.getAttribute("data-value"));
		ase.readOnly = true;
		document.getElementById("combobox-id-da-search-field-x").style.display = "block";
		document.getElementById("combobox-id-da-search-field-info").style.display = "none";
		OEAddressSearchPhraseNew = element.title;

		BulkUtils.closeAddressSearch();
	},
	//CHECK : Do we need this method??
	closeAddressSearch: function () {
		let lp = document.getElementById("lookup-id-address-search");
		lp.classList.remove("slds-is-open");
	},


	doContactSearch: async function () {
		let currentBasket = await CS.SM.getActiveBasket();
		if (isReadOnlyModeNew) return;
		BulkUtils.closeAddressSearch();

		let cse = document.getElementById("combobox-id-dc-search-field");
		if (!cse || cse.readOnly) return;
		if (OEContactSearchPhraseNew === cse.value && OEContactSearchResultNew && OEContactSearchResultNew.length > 0) {
			BulkUtils.populateContactLookup(OEContactSearchResultNew);
			return;
		}

		BulkUtils.showFetchingValuesLine(false);
		var input = {};
		input["basketId"] = currentBasket.basketId;
		input["searchString"] = cse.value;
		input["option"] = "contact";
		await currentBasket.performRemoteAction("GetDeliveryDetailsLookupValues", input).then(function (values) {
			OEContactSearchPhraseNew = cse.value;
			OEContactSearchResultNew = values.contact;
			BulkUtils.populateContactLookup(values.contact);
			cse.focus();
		});
		return Promise.resolve(true);
	},

	populateContactLookup:function(records) {
		let lb = document.getElementById("listbox-id-contact-search");
		let lp = document.getElementById("lookup-id-contact-search");
		lb.innerHTML = "";
		if (records && records.length > 0) {
			lb.innerHTML = BulkUtils.getContactLookupResultList(records);
			lp.classList.add("slds-is-open");
		} else {
			lb.innerHTML = BulkUtils.getNoDataLine();
			if (OETimeoutNoDataNew) clearTimeout(OETimeoutNoDataNew);
			//CHECK : need to remove setTimeout? how??
			OETimeoutNoDataNew = setTimeout(() => {
				lp.classList.remove("slds-is-open");
			}, 2000);
		}
	},

	showFetchingValuesLine:function(isAddresSearch) {
		if (OETimeoutNoDataNew) clearTimeout(OETimeoutNoDataNew);
		let line =
			'<ul class="slds-listbox slds-listbox_vertical" role="presentation">' +
			'<li role="presentation" class="slds-listbox__item">' +
			'<div id="option-fetching-values" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" role="option" >' +
			'<span class="slds-media__body">' +
			'<span  class="slds-truncate">Fetching values... </span>' +
			"</span>" +
			"	</div>" +
			"</li>" +
			"</ul>";
		if (isAddresSearch) {
			let lb = document.getElementById("listbox-id-address-search");
			let lp = document.getElementById("lookup-id-address-search");
			lb.innerHTML = line;
			lp.classList.add("slds-is-open");
		} else {
			let lb = document.getElementById("listbox-id-contact-search");
			let lp = document.getElementById("lookup-id-contact-search");
			lb.innerHTML = line;
			lp.classList.add("slds-is-open");
		}
	},


	getNoDataLine: function () {
		return (
			'<ul class="slds-listbox slds-listbox_vertical" role="presentation">' +
			'<li role="presentation" class="slds-listbox__item">' +
			'<div id="option-fetching-values" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" role="option" >' +
			'<span class="slds-media__body">' +
			'<span  class="slds-truncate">No data</span>' +
			"</span>" +
			"	</div>" +
			"</li>" +
			"</ul>"
		);
	},


	onConfigurationPreview: async function (row, tabName) {
		let currentBasket = await CS.SM.getActiveBasket();
		persistentValuesNew = {};
		let configId = row.getAttribute("data-value");
		if (!configId) return;


		let spinner = document.getElementById("row-loading-" + tabName + "-" + configId);
		if (spinner) {
			spinner.style.display = "block";
		}


		let config = OEConfigurationsNew.find((e) => e.guid === configId);
		if (!config || config.length === 0) return;
		if (!config.orderEnrichmentList) return;
		let deliveryContactId;
		let deliveryAddressId;
		deliveryContactId = config.SiteDeliveryContact;
		deliveryAddressId = config.SiteDeliveryAddress;


		if (deliveryContactId || deliveryAddressId) {
			persistentValuesNew["Not Before CRD"] = config.NotBeforeCRD;
			persistentValuesNew["Preferred CRD"] = config.PreferredCRD;
			persistentValuesNew["Notes"] = config.Notes;
			if (config.INTROAM === "Yes") persistentValuesNew["International Roaming"] = true;
			else {
				persistentValuesNew["International Roaming"] = false;
			}
			persistentValuesNew["Call Restriction"] = config.CallRestriction;
		}
		if (!deliveryContactId || !deliveryAddressId) {
			config.orderEnrichmentList.forEach((oe) => {
				if (oe.attributes) {
					Object.values(oe.attributes).forEach((a) => {
						if (a.name === "DeliveryContact") {
							deliveryContactId = a.value;
						} else if (a.name === "DeliveryAddress") {
							deliveryAddressId = a.value;
						}


						if (a.type === "Boolean") {
							persistentValuesNew[a.name] = a.value === "Yes" ? true : false;
						} else if (a.type === "Date" && a.value) {
							persistentValuesNew[a.name] = Utils.formatDate(a.value);
						} else {
							persistentValuesNew[a.name] = a.displayValue;
						}
					});
				}
			});
		}


		if (deliveryAddressId) {
			let input = {};
			input["basketId"] = currentBasket.basketId;
			input["searchString"] = deliveryAddressId;
			input["option"] = "addresses";
			await currentBasket.performRemoteAction("GetDeliveryDetailsLookupValues", input).then(function (values) {
				if (values.addresses && values.addresses.length) {
					persistentValuesNew["DeliveryAddress"] = JSON.stringify(values.addresses[0]);
				}
			});
		}


		if (deliveryContactId) {
			let input = {};
			input["basketId"] = currentBasket.basketId;
			input["searchString"] = deliveryContactId;
			input["option"] = "contact";
			await currentBasket.performRemoteAction("GetDeliveryDetailsLookupValues", input).then(function (values) {
				if (values.contact && values.contact.length) {
					persistentValuesNew["DeliveryContact"] = JSON.stringify(values.contact[0]);
				}
			});
		}

		BulkUtils.restoreValuesForCurrentTab();
		let tabs = document.getElementsByClassName("slds-path__link");
		let selectedTab;
		for (let i = 0; i < tabs.length; i++) {
			if (tabs[i].id.includes("oe-tab-default-")) {
				if (tabs[i].getAttribute("aria-selected") === "true") {
					selectedTab = tabs[i];
				}
			}
		}
		document.getElementById("oe-tab-default-3__item").click();
		document.getElementById("oe-tab-default-2__item").click();
		document.getElementById("oe-tab-default-1__item").click();

		if (selectedTab) {
			selectedTab.click();
		}
		isPreviousSelectionCompleteNew = true;
		if (spinner) {
			spinner.style.display = "none";
		}
		return Promise.resolve(true);
	},


	getAttributeMap: function () {
		if (isReadOnlyModeNew) return;
		let inputs = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt");
		let lookups = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-lookup");
		let inputselect = document.getElementsByClassName("slds-show")[0].children[0].getElementsByClassName("inpt-select");
		let allItems = [];
		allItems = Array.prototype.concat.apply(allItems, inputs);
		allItems = Array.prototype.concat.apply(allItems, inputselect);
		let attributeMap = [];
		let attrs = {};
		for (let i = 0; i < allItems.length; i++) {
			let type = allItems[i].getAttribute("type");
			if (type && type === "checkbox") {
				attrs[allItems[i].getAttribute("attName")] = allItems[i].checked ? "Yes" : "No";
			} else {
				attrs[allItems[i].getAttribute("attName")] = allItems[i].value;
			}
		}


		for (let i = 0; i < lookups.length; i++) {
			let attName = lookups[i].getAttribute("attName");
			if (attName.includes("DeliveryContact")) {
				let parsedData = lookups[i].getAttribute("data-value") ? JSON.parse(lookups[i].getAttribute("data-value")) : {};
				attrs["DeliveryContact"] = parsedData.Id ? parsedData.Id : "";
				attrs["Name"] = parsedData.Name ? parsedData.Name : "";
				attrs["FirstName"] = parsedData.FirstName ? parsedData.FirstName : "";
				attrs["LastName"] = parsedData.LastName ? parsedData.LastName : "";
				attrs["Phone"] = parsedData.Phone ? parsedData.Phone : "";
				attrs["Mobile"] = parsedData.MobilePhone ? parsedData.MobilePhone : "";
				attrs["Email"] = parsedData.Email ? parsedData.Email : "";
				attrs["IsDeliveryDetailsEnriched"] = attrs["DeliveryContact"] && attrs["DeliveryAddress"] ? true : false;
			} else if (attName.includes("DeliveryAddress")) {
				let parsedData = lookups[i].getAttribute("data-value") ? JSON.parse(lookups[i].getAttribute("data-value")) : {};
				attrs["DeliveryAddress"] = parsedData.Id ? parsedData.Id : "";
				attrs["ADBOIRId"] = parsedData.Address_ID__c ? parsedData.Address_ID__c : "";
				attrs["Postcode"] = parsedData.cscrm__Zip_Postal_Code__c ? parsedData.cscrm__Zip_Postal_Code__c : "";
				attrs["Street"] = parsedData.Street_calc__c ? parsedData.Street_calc__c : "";
				attrs["Address"] = parsedData.Name ? parsedData.Name : "";
				attrs["IsDeliveryDetailsEnriched"] = attrs["DeliveryContact"] && attrs["DeliveryAddress"] ? true : false;
			} else {
				attrs[attName] = JSON.parse(lookups[i].getAttribute("data-value"));
			}
		}
		attributeMap.push(attrs);
		return attributeMap;
	},


	doAddressSearch: async function () {
		let currentBasket = await CS.SM.getActiveBasket();
		if (isReadOnlyModeNew) return;
		BulkUtils.closeContactSearch();
		var ase = document.getElementById("combobox-id-da-search-field");
		if (!ase || ase.readOnly) return;
		if (OEAddressSearchPhraseNew === ase.value && OEAddressSearchResultNew && OEAddressSearchResultNew.length > 0) {
			BulkUtils.populateAddressLookup(OEAddressSearchResultNew);
			return;
		}
		BulkUtils.showFetchingValuesLine(true);
		var input = {};
		//input["basketId"] = CS.SM.session.basketId;
		input["basketId"] = currentBasket.basketId;
		input["searchString"] = ase.value; //ase.value;
		input["option"] = "addresses";
		await currentBasket.performRemoteAction("GetDeliveryDetailsLookupValues", input).then(function (values) {
			OEAddressSearchPhraseNew = ase.value;
			OEAddressSearchResultNew = values.addresses;
			BulkUtils.populateAddressLookup(values.addresses);
			ase.focus();
		});
		return Promise.resolve(true);
	},


	populateAddressLookup: function (records) {
		let lb = document.getElementById("listbox-id-address-search");
		let lp = document.getElementById("lookup-id-address-search");
		lb.innerHTML = "";
		if (records && records.length > 0) {
			lb.innerHTML = BulkUtils.getAddressLookupResultList(records);
			lp.classList.add("slds-is-open");
		} else {
			lb.innerHTML = BulkUtils.getNoDataLine();
			if (OETimeoutNoDataNew) clearTimeout(OETimeoutNoDataNew);
			//CHECK
			OETimeoutNoDataNew = setTimeout(() => {
				lp.classList.remove("slds-is-open");
			}, 2000);
		}
	},


	closeContactSearch: function () {
		let lp = document.getElementById("lookup-id-contact-search");
		lp.classList.remove("slds-is-open");
	},


	addressSearchKeyUp: function (event) {
		if (event.key === "Enter") {
			BulkUtils.doAddressSearch();
		} else {
			if (OETimeoutAddressSearchNew) clearTimeout(OETimeoutAddressSearchNew);
			OETimeoutAddressSearchNew = setTimeout(BulkUtils.doAddressSearch, 500);
		}
	},


	contactSearchKeyUp: function (event) {
		if (event.key === "Enter") {
			BulkUtils.doContactSearch();
		} else {
			if (OETimeoutContactSearchNew) clearTimeout(OETimeoutContactSearchNew);
			OETimeoutContactSearchNew = setTimeout(BulkUtils.doContactSearch, 500);
		}
	},


	validateControl: function (ctl, id) {
		if (ctl) {
			let icon = document.getElementById(id);
			if (icon) {
				if (ctl.value) {
					icon.style.display = "none";
				} else {
					icon.style.display = "block";
				}
			}
		}
	},


	selectContact: function (element) {
		let ase = document.getElementById("combobox-id-dc-search-field");
		ase.value = element.title;
		ase.setAttribute("data-value", element.getAttribute("data-value"));
		ase.readOnly = true;
		document.getElementById("combobox-id-dc-search-field-x").style.display = "block";
		document.getElementById("combobox-id-dc-search-field-info").style.display = "none";
		OEContactSearchPhraseNew = element.title;
		BulkUtils.closeContactSearch();
	},


	//EDGE-172941 INC000093743308 Fix
	getProdNumber: async function () {
		let pcidList = [];
		let solution = await CS.SM.getActiveSolution();
		let currentBasket = await CS.SM.getActiveBasket();
		if (solution.components && Object.values(solution.components).length > 0) {
			var component = solution.getComponentByName(bulkOEComponentNameNew);
		}
		//if(solution.components && Object.values(solution.components).length > 0){
		//Object.values(solution.components).forEach(async function (component) {
		//if (component.name === bulkOEComponentNameNew) {
		if (component.schema.configurations && Object.values(component.schema.configurations).length > 0) {


			//Object.values(component.schema.configurations).forEach((config) => 
			for(var config of Object.values(component.schema.configurations)){
				if(!config.disabled && (config.id && config.id!='' && config.id != null && config.id!='undefined')) // INC000093907636 Fix
			        pcidList.push(config.id);
			}


		}
		//}
		//});
		//}
		let inputMap = {};
		inputMap["getPCId"] = pcidList.toString();
		await currentBasket.performRemoteAction("SolutionActionHelper", inputMap).then((result) => {
			retMapOE = result;
		});
		return Promise.resolve(true);
	}
	//EDGE-172941 INC000093743308 Fix End


	// These methods are called in this file , so removed for now.
	// mydatehidden, mydateToformateddate, getAttributeDeliveryMap.ReadOnlyMobileFeature
};