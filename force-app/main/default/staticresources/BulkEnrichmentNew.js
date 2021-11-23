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
8.Sandhya   05/10/2020 // INC000093907636 Fix
Description :  Js for order enrichment rules for UI (new Java script)
*/
console.log('BulkcreateOELogic::::::');
let deliveryDetailsHtmlNew = '';
let deliveryDetailsAddressHtmlNew = '';
let deliveryDetailsContactHtmlNew = '';
let crdHtmlNew = '';
let mfHtmlNew = '';
let persistentValuesNew = {};
let allOeValuesNew = {};
let bulkOEComponentNameNew;
let OESchemaIdMapNew=[];
let OEConfigurationsNew=[];
let OEAddressSearchResultNew=[];
let OEAddressSearchPhraseNew;
let OETimeoutAddressSearchNew;
let OEContactSearchResultNew=[];
let OEContactSearchPhraseNew;
let OETimeoutContactSearchNew;
let OETimeoutNoDataNew;
let isReadOnlyModeNew = false;
let isMacdOrederNew = false;
let OEStartXNew;
let OEColumnWidthNew;
let OEColumnToResizeNew;
let isPreviousSelectionCompleteNew = true;
let oeGuidMap=new Map();
let  retMapOE = {};

const tooltipElementNew = '<div class="tooltip icon-info" id="help"  style="position:absolute; top:-3px; right:-20px;">'
	+ '<span class="tooltip-arrow"></span>'
	+ '<span class="slds-form-element__help tooltip-text">This value can not be empty</span>'
	+ '</div>';
async function BulkcreateOELogic(solutionName, componentName) {
	bulkOEComponentNameNew = componentName;
	isPreviousSelectionCompleteNew = true;
	deliveryDetailsHtmlNew = '';
	deliveryDetailsAddressHtmlNew = '';
	deliveryDetailsContactHtmlNew= '';
	crdHtmlNew = '';
	mfHtml = '';
	OESchemaIdMapNew = [];
	OEConfigurationsNew = [];
	OEAddressSearchPhraseNew = '';
	OEContactSearchPhraseNew = '';
	OEAddressSearchResultNew = [];
	OEContactSearchResultNew = [];
	persistentValuesNew = {};
	allOeValuesNew = {};
    oeGuidMap=new Map();
	await BulkUtils.populateSchemaIds();
	await BulkUtils.getProdNumber(); //EDGE-172941 INC000093743308 Fix
	await BulkUtils.fetchConfigurations();
	document.getElementsByClassName('slds-text-heading_medium')[0].style.display = 'none';
	var table =
		'<div class="modal-header slds-modal__header">'
		+ '<h2 class="title slds-text-heading--medium slds-hyphenate">'
		+ '<div class="appLauncherModalHeader slds-grid slds-grid--align-spread  slds-m-right--small slds-m-left--small slds-grid--vertical-align-center slds-text-body--regular">'

		+ '<div>'
		+ '<h2 class="slds-text-heading--medium">Bulk Enrichment Console - ' + solutionName + '</h2>'
		+ '</div>'

		+ '<div>'
		+ '<span class="icon-close" onclick="BulkUtils.closeOe()" />'
		+ '</div>'

		+ '</div>'

		+ '</h2>'
		+ '</div>'
		+ '</BR><div id="errorPannel" class="slds-theme_error"></div></BR>';
		
	table += '<div class="slds-col slds-size_3-of-3" id="main-nav-div-1">'
		+ '<div class="slds-path">'
		+ '  <ul class="slds-path__nav" role="listbox">'
		+ '    <li class="slds-path__item slds-is-error slds-is-active slds-size_1-of-3" id="OEtab_1"  title="Delivery Details" role="presentation" onclick="BulkUtils.setActive(this)">'
		+ '      <a class="slds-path__link " href="javascript:void(0);" role="option" tabindex="0" aria-selected="true" aria-controls="oe-tab-default-1" name="Delivery details" id="oe-tab-default-1__item"><span class="slds-path__stage"><div class="slds-icon slds-icon_x-small icon-warning" id="oe-tab-delivery__item"></div></span><span> Delivery Details</span></a>'
		+ '    </li>'
		+ '    <li class="slds-path__item slds-is-error slds-size_1-of-3"  title="Customer Requested Dates" role="presentation"  id="OEtab_2" onclick="BulkUtils.setActive(this)">'
		+ '      <a class="slds-path__link " href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-2" name="Customer requested Dates" id="oe-tab-default-2__item"> <span class="slds-path__stage"><div class="slds-icon slds-icon_x-small icon-warning"   id="oe-tab-CRD__item"></div></span><span>Customer Requested Dates</span></a>'
		+ '    </li>'
		+ '    <li class="slds-path__item slds-is-complete slds-size_1-of-3" title="Features" role="presentation"  id="OEtab_3" onclick="BulkUtils.setActive(this)">'
		+ '      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-3" name="Mobility features" id="oe-tab-default-3__item"><span class="slds-path__stage"><div class="slds-icon slds-icon_x-small icon-check" id="oe-tab-Features__item"></div></span><span>Features</span></a>'
		+ '    </li>'
		+ '  </ul>'
		+ '</div>'
		+ '</div>'
		+ '<div class="modal-header slds-modal__header">'
		+ '</div>';
	table += '<div class="slds-grid slds-gutters" >'

		+ '<span class="slds-spinner_container" style="display: none; position:absolute; top:350px" id="main-save-spinner-1">'
		+'<div role="status" class="slds-spinner slds-spinner slds-spinner_large slds-spinner_brand">'
		+'<span class="slds-assistive-text">Saving</span>'
		+'<div class="slds-spinner__dot-a"></div>'
		+'<div class="slds-spinner__dot-b"></div>'
		+'</div>'
		+'</span>'
		+ '<div class="slds-col slds-size_3-of-6" onmousemove="BulkUtils.handlemousemove(event)" onmouseup="BulkUtils.handlemouseup(event)">'
		+ '<div class="slds-grid slds-gutters" style="margin-bottom: 10px">'
		+ '<div class="slds-col ">'
		+ '<input class="slds-input" type="text" placeholder="Search..." id="configurationSearch" attName="configurationSearch" value=""' 
		+ '  onkeyup="BulkUtils.configurationSearchKeyUp(event)" /> '
		+ '</div>'
		+ '</div>'
		+ '<div class="slds-table_header-fixed_container slds-border_top slds-border_bottom slds-border_right slds-border_left"  style="height:110px;overflow-y: scroll;">'
		//style="height:400px;"
		+ '<div id="tableViewInnerDiv" class="tableViewInnerDiv" style="height:100%;">'
		+ '<table aria-multiselectable="true" role="grid" class="slds-table slds-table_header-fixed  slds-table_bordered  slds-table_fixed-layout slds-table_resizable-cols">'
		+ '<thead>'
		+ '<tr class="">';
		
		table += '<th   scope="col" style="width:32px">'
			+ '<span id="column-group-header" class="slds-assistive-text">Choose a row</span>'
			+ '<div class="slds-th__action slds-th__action_form slds-align_absolute-center slds-cell-fixed">'
			+ '<div class="slds-checkbox ">'
			+ '<input type="checkbox" class="pc-selection_all" name="options" id="checkboxAll" value="checkboxAll" tabindex="-1" aria-labelledby="check-select-all-label column-group-header"  onclick="BulkUtils.updateSelectAll('+'\''+'Yes'+'\''+')" />'
			+ '<label class="slds-checkbox__label" for="checkboxAll" id="check-select-all-label">'
			+ '<span class="slds-checkbox_faux"></span>'
			+ '  <span class="slds-form-element__label slds-assistive-text">Select All</span>'
			+ '</label>'
			+ '</div>'
			+ '</div>'
			+ '</th>';
	

	table += ' <th aria-label="Name" aria-sort="none" class="slds-is-resizable dv-dynamic-width"  style="text-align:center; width: 350px" scope="col">'
		+ ' <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center dv-dynamic-width" style="width: 350px">'
		+ '   <span class="slds-truncate">&nbsp;&nbsp;&nbsp;Name</span>'
		+ '<div class="slds-resizable">'
		+ '<span class="slds-resizable__handle" onmousedown="BulkUtils.handlemousedown(event)">'
		+ '<span class="slds-resizable__divider"></span>'
		+ '</span>'
		+ '</div>'
		+ '</div>'

		+ ' </th>'

	
		table += ' <th aria-label="Model" aria-sort="none" class="slds-is-resizable" style="text-align:center; width: 60px" scope="col">'
		+ '    <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center slds-align_absolute-center">Enriched</div>'
		+ '  </th>';
	

	table += '</tr>'
		+ '</thead>'
		+ '<tbody id="config_table_scrollable_container">';

	table += BulkUtils.createConfigTableRows('','DeliveryTab');
	table += BulkUtils.createConfigTableRows('','CRDTab');
	table += BulkUtils.createConfigTableRows('','FeatureTab');
	
	table += '</tbody>'
		+ '</table>'
		+ '</div>'
		+ '</div></div>';
  
	table+= ' <div class="slds-col slds-size_1-of-2 slds-scrollable" style="max-height:120px" ><div id="oe-tab-default-1" class="slds-tabs_default__content slds-show" role="tabpanel" aria-labelledby="oe-tab-default-1__item"><div id="delivery_oe"></div></div>'
		+ '<div id="oe-tab-default-2" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-2__item"><div id="crd_oe"></div></div>'
		+ '<div id="oe-tab-default-3" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-3__item"><div id="features_oe"></div></div></div></div>'
	table += '<div><div style="margin-top: 10px;  margin-bottom: 10px">'
			+ '<button class="slds-button slds-button_neutral slds-float_right"  onclick="BulkUtils.closeOe()">Cancel</button>'
			+ '<button class="slds-button slds-button_neutral slds-float_right" onclick="BulkUtils.saveOEForSelectedConfigs(false)">Save</button>'
			+ '</div></div>';
	
		var container = document.getElementsByClassName('container');
		container[0].innerHTML = table.trim();
		container[0].style.padding = "15px";
		let tableValuePopulateNew= BulkUtils.isOredrEnrichmentDoneForConfigurationStatus(OEConfigurationsNew);
		
		if(tableValuePopulateNew)
			BulkUtils.prepareDeliveryDetails();
		if(!tableValuePopulateNew){
			BulkUtils.drawNoupdateRequiredDetails('delivery_oe');
			BulkUtils.drawNoupdateRequiredDetails('features_oe');
			BulkUtils.drawNoupdateRequiredDetails('crd_oe');
			let detabdeCancel = document.getElementById('OEtab_1');
			let iconForbeforCRDcancel = document.getElementById('OEtab_2');
			iconForbeforCRDcancel.classList.remove('slds-is-error');
			iconForbeforCRDcancel.classList.add('slds-is-complete');
			detabdeCancel.classList.remove('slds-is-error');
			detabdeCancel.classList.add('slds-is-complete');
			
			let detabdeCancelTab = document.getElementById('oe-tab-delivery__item');
			let iconForbeforCRDcancelTab = document.getElementById('oe-tab-CRD__item');
			detabdeCancelTab.classList.remove('icon-warning');
			detabdeCancelTab.classList.add('icon-check');
			iconForbeforCRDcancelTab.classList.remove('icon-warning');
			iconForbeforCRDcancelTab.classList.add('icon-check');
		}
		
		if(tableValuePopulateNew){
			crdHtmlNew = await BulkUtils.prepareOETable('Customer requested Dates');
			mfHtmlNew = await BulkUtils.prepareOETable('Mobility features');
		
			document.getElementById('oe-tab-default-3__item').click();
			document.getElementById('oe-tab-default-2__item').click();
			document.getElementById('oe-tab-default-1__item').click();
			
			 BulkUtils.tabForDeliveryDetails();
			 BulkUtils.TabForCRD();
		}
	return Promise.resolve(true);
}


var BulkUtils = {
	markConfigurationEnrichmentStatus:function(guid, isEnriched,tabName) {
		console.log('markConfigurationEnrichmentStatus isEnriched',  isEnriched);
		console.log('markConfigurationEnrichmentStatus tabName',  tabName);

		let notEnrichedIcon = document.getElementById('row-not-enriched-'+tabName+'-'+ guid);
		let enrichedIcon = document.getElementById('row-enriched-'+tabName+'-'+ guid);
		if (isEnriched) {
			enrichedIcon.style.display = 'block';
			notEnrichedIcon.style.display = 'none';
		} else {
			enrichedIcon.style.display = 'none';
			notEnrichedIcon.style.display = 'block';
		}
	},
 	createConfigTableRows: function(filterPhrase,tabName) {
		let table = '';
		//let tableValuePopulate= BulkUtils.isOredrEnrichmentDoneForConfigurationStatus(OEConfigurationsNew);
		for (let i = 0; i < OEConfigurationsNew.length; i++) {
			let row = OEConfigurationsNew[i];

			if (filterPhrase && (!row.searchField.toLowerCase().includes(filterPhrase.toLowerCase())))
				continue;
       		// if(tableValuePopulate){
			table += '<tr  class="slds-hint-parent" id="Check_Details_'+tabName+i+'"'+ 'onclick="BulkUtils.onConfigurationClick(event, this,'+'\''+tabName+'\''+')" data-value="' + row.guid + '">';
			if (!isReadOnlyModeNew) {
				table += '<td style="width:30px" class="slds-text-align_left" role="gridcell">'
					+ '    <div class="slds-checkbox slds-align_absolute-center" >\n'
					+ '       <input type="checkbox" class="pc-selection" name="options" id="checkbox-'+tabName+'-' + row.guid + '" value="' + row.guid + '" tabindex="0" aria-labelledby="' + row.guid + ' column-group-header" onclick="BulkUtils.markSelection(event, this)"/>\n'
					+ '       <label class="slds-checkbox__label" for="checkbox-'+tabName+'-'+ row.guid + '" id="' + row.guid +'-'+tabName+ '">\n'
					+ '          <span class="slds-checkbox_faux"></span>\n'
					+ '          <span class="slds-form-element__label slds-assistive-text">Select item'
					+ row.name
					+ '</span>\n'
					+ '       </label>\n'
					+ '    </div>'
					+ '</td>';
			}
			if(row.CustomerFacingServiceId){
			table += '<td  class="slds-text-align_left slds-truncate" role="gridcell">'
				+ '<div class="slds-truncate" title="' + row.name + '">'
				+row.name+'-'+row.CustomerFacingServiceId
				+'<br/>'
				+row.modelName;
				+ '</div>'
				+ '</td>';
			}
			else{
			table += '<td  class="slds-text-align_left slds-truncate" role="gridcell">'
				+ '<div class="slds-truncate" title="' + row.name + '">'
				+ row.name
				+'<br/>'
				+row.modelName;
				+ '</div>'
				+ '</td>';
			}
			if (!isReadOnlyModeNew) {
				let oeDone = BulkUtils.isOredrEnrichmentDoneForConfiguration(row.orderEnrichmentList);

				table += '<td  class="slds-text-align_center" role="gridcell">';

				//spinner
				table += '<span class="slds-spinner_container" style="display: none" id="row-loading-'+tabName+'-'+ row.guid + '">'
					+'<div role="status" class="slds-spinner slds-spinner_small slds-spinner_brand">'
					+'<div class="slds-spinner__dot-a"></div>'
					+'<div class="slds-spinner__dot-b"></div>'
					+'</div>'
					+'</span>';

				//ticked icon for enriched row
				if(tabName==='DeliveryTab'){
					table += '    <span class="icon-check"   id="row-enriched-DeliveryTab-' + row.guid + '"';
					if (!row.IsDeliveryDetailsEnriched) {
						table += ' style="display: none" >';
					}

					table += '</span>';

					// warning info icon foe not enriched rows
					table += '<span class="icon-warning"  id="row-not-enriched-DeliveryTab-' + row.guid + '"';
					if (row.IsDeliveryDetailsEnriched) {
						table += ' style="display: none" >';
					}
					else{
						table += ' style="color: red" >';
					}
					table += '</span>'
				}
				if(tabName==='CRDTab'){
					table += '    <span class="icon-check"   id="row-enriched-CRDTab-' + row.guid + '"';
					if (!row.IsCRdEnriched) {
						table += ' style="display: none" >';
					}

					table += '</span>';

					// warning info icon foe not enriched rows
					table += '<span class="icon-warning"  id="row-not-enriched-CRDTab-' + row.guid + '"';
					if ( row.IsCRdEnriched) {
						table += ' style="display: none" >';
					}
					else{
						table += ' style="color: red" >';
					}
					table += '</span>'
				}
				if(tabName==='FeatureTab'){
					table += '    <span class="icon-check"   id="row-enriched-FeatureTab-' + row.guid + '"';
					/*if (!oeDone) {
						table += ' style="display: none" >';
					}*/

					table += '</span>';

					// warning info icon foe not enriched rows
					/*table += '<span class="icon-warning"  id="row-not-enriched-FeatureTab-' + row.guid + '"';
					if (oeDone) {
						table += ' style="display: none" >';
					}
					else{
						table += ' style="color: red" >';
					}
					table += '</span>'*/
				}
					+ '</td>';
			}
			table += '</tr>';
		//}
		}

		return table;
	},
	showOnlyDeliveryConfiguration : function(){
		for (let i = 0; i < OEConfigurationsNew.length; i++) {
			let row = OEConfigurationsNew[i];
			let dev=document.getElementById('Check_Details_DeliveryTab'+i);
			let dev1=document.getElementById('Check_Details_CRDTab'+i);
			let dev2=document.getElementById('Check_Details_FeatureTab'+i);
			if(row.isDeliveryDetailsRequired==='true' ||row.isDeliveryDetailsRequired=== true){
				dev.classList.remove('slds-hide');
			}else{
				dev.classList.add('slds-hide');
			}
			dev1.classList.add('slds-hide');
			dev2.classList.add('slds-hide');
		}
	},
	showOnlyCRDConfiguration :function(){
		for (let i = 0; i < OEConfigurationsNew.length; i++) {
			let row = OEConfigurationsNew[i];
			let dev=document.getElementById('Check_Details_DeliveryTab'+i);
			let dev1=document.getElementById('Check_Details_CRDTab'+i);
			let dev2=document.getElementById('Check_Details_FeatureTab'+i);
			if(row.isCRDDatesRequired==='true' ||row.isCRDDatesRequired=== true){
				dev1.classList.remove('slds-hide');
			}else{
				dev1.classList.add('slds-hide');
			}
			dev.classList.add('slds-hide');
			dev2.classList.add('slds-hide');
		}
	},
	showOnlyFeatureConfiguration :function	(){
		for (let i = 0; i < OEConfigurationsNew.length; i++) {
			let row = OEConfigurationsNew[i];
			let dev=document.getElementById('Check_Details_DeliveryTab'+i);
			let dev1=document.getElementById('Check_Details_CRDTab'+i);
			let dev2=document.getElementById('Check_Details_FeatureTab'+i);
			if(row.isFeaturesRequired==='true' ||row.isFeaturesRequired=== true){
				dev2.classList.remove('slds-hide');
			}else{
				dev2.classList.add('slds-hide');
			}
			dev.classList.add('slds-hide');
			dev1.classList.add('slds-hide');
		}
	},
	handlemousedown:function(e) {
		//console.log('handlemousedown', e);
		OEColumnToResizeNew = document.querySelectorAll("table thead .dv-dynamic-width");
		if (OEColumnToResizeNew && OEColumnToResizeNew.length>0)  {
			OEStartXNew = e.screenX;
			OEColumnWidthNew = parseInt(OEColumnToResizeNew[0].style.width, 10);
		}
	},

	 handlemouseup:function(e) {
		//console.log('handlemouseup', e);
		OEStartXNew = undefined;
		OEColumnToResizeNew = undefined;
	},


	handlemousemove: function(e) {
		if (OEStartXNew && OEColumnToResizeNew) {
		//	console.log('handlemousemove OEStartXNew', OEStartXNew);
			let width = OEColumnWidthNew +  e.screenX - OEStartXNew;
			//console.log('handlemousemove dif', dif)
			if (width > 50) {
				OEColumnToResizeNew.forEach((c) => {
					c.style.width = width + 'px';
				});
			}

		}
	},
	onConfigurationClick:async function(ev, row,tabName) {

		if (!isPreviousSelectionCompleteNew)
			return;

		if (ev.target.className.includes('checkbox'))
			return;

		isPreviousSelectionCompleteNew = false;

		//if (!isReadOnlyModeNew) {
		//Aditya Fixes EDGE-130398
			if (basketStage == 'Contract Accepted' || (basketStage == 'Enriched')|| (basketStage == 'Submitted')){
						console.log('at341', basketStage);
			await BulkUtils.onConfigurationPreview(row,tabName);
			console.log('at344', basketStage);
			return Promise.resolve(true);
		}

		persistentValuesNew = {};

		let configId = row.getAttribute('data-value');
		if (!configId)
			return;

		let config = OEConfigurationsNew.filter(e => {
			return e.guid === configId
		});
		if (!config || config.length === 0)
			return;
		if (!config[0].orderEnrichmentList)
			return;
		config[0].orderEnrichmentList.forEach((oe) => {
			if (oe.attributes) {
				//oe.attributes.forEach((a) => {
				Object.values(oe.attributes).forEach((a) => {
					if (a.type === 'Boolean') {
						persistentValuesNew[a.name] = a.value === 'Yes' ? true : false;
					} else if (a.type === 'Date' && a.value) {
						persistentValuesNew[a.name] = Utils.formatDate(a.value);
					} else {
						persistentValuesNew[a.name] = a.displayValue;
					}
				});
			}
		});

		BulkUtils.restoreValuesForCurrentTab();

		let tabs = document.getElementsByClassName('slds-path__link');
		for (let i = 0; i < tabs.length; i++) {
			if (tabs[i].getAttribute('aria-selected') === 'true' && tabs[i].id.includes('oe-tab-default-')) {
				tabs[i].click();
				break;
			}
		}

		isPreviousSelectionCompleteNew = true;

		return Promise.resolve(true);
	},

	onConfigurationPreview:async function (row,tabName) {

		let currentBasket = await CS.SM.getActiveBasket();
		persistentValuesNew = {};

		let configId = row.getAttribute('data-value');
		if (!configId)
			return;

		let spinner = document.getElementById('row-loading-'+tabName+'-'+ configId);
		if (spinner) {
			spinner.style.display = 'block';
		}

		let config = OEConfigurationsNew.filter(e => {
			return e.guid === configId
		});
		if (!config || config.length === 0)
			return;
		if (!config[0].orderEnrichmentList)
			return;

		let deliveryContactId;
		let deliveryAddressId;
		
		deliveryContactId=config[0].SiteDeliveryContact;
		deliveryAddressId=config[0].SiteDeliveryAddress;

		console.log('deliveryContactId >> ' , deliveryContactId);
		console.log('deliveryAddressId >> ' , deliveryAddressId);

		if(deliveryContactId || deliveryAddressId){
			persistentValuesNew["Not Before CRD"]=config[0].NotBeforeCRD;
			persistentValuesNew["Preferred CRD"]=config[0].PreferredCRD;
			persistentValuesNew["Notes"]=config[0].Notes;
			if(config[0].INTROAM==='Yes')
				persistentValuesNew["International Roaming"]=true;
			else{
				persistentValuesNew["International Roaming"]=false;
			}
			persistentValuesNew["Call Restriction"]=config[0].CallRestriction;
		}
		if(!deliveryContactId || !deliveryAddressId){
			config[0].orderEnrichmentList.forEach((oe) => {
				if (oe.attributes) {
					Object.values(oe.attributes).forEach((a) => {
						if (a.name === 'DeliveryContact') {
							deliveryContactId = a.value;
						} else if (a.name === 'DeliveryAddress') {
							deliveryAddressId = a.value;
						}

						if (a.type === 'Boolean') {
							persistentValuesNew[a.name] = a.value === 'Yes' ? true : false;
						} else if (a.type === 'Date' && a.value) {
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
			//input["basketId"] = CS.SM.session.basketId;
			input["basketId"] = currentBasket.basketId;
			input["searchString"] = deliveryAddressId;
			input["option"] = 'addresses';
			//await CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
			await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
			//	console.log('GetDeliveryDetailsLookupValues', values);
				if (values.addresses && values.addresses.length) {
					persistentValuesNew['DeliveryAddress'] = JSON.stringify(values.addresses[0]);
				}
			});
		}

		if (deliveryContactId) {
			let input = {};
			//input["basketId"] = CS.SM.session.basketId;
			input["basketId"] = currentBasket.basketId;
			input["searchString"] = deliveryContactId;
			input["option"] = 'contact';
			//await CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
			await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
				if (values.contact && values.contact.length) {
					persistentValuesNew['DeliveryContact'] = JSON.stringify(values.contact[0]);
				}
			});
		}

		BulkUtils.restoreValuesForCurrentTab();

		let tabs = document.getElementsByClassName('slds-path__link');
		let selectedTab;
		for (let i = 0; i < tabs.length; i++) {
			if (tabs[i].id.includes('oe-tab-default-')) {
				if (tabs[i].getAttribute('aria-selected') === 'true') {
					selectedTab = tabs[i];
				}
			}
		}
		document.getElementById('oe-tab-default-3__item').click();
		document.getElementById('oe-tab-default-2__item').click();
		document.getElementById('oe-tab-default-1__item').click();

		if (selectedTab) {
			selectedTab.click();
		}

		isPreviousSelectionCompleteNew = true;
		if (spinner) {
			spinner.style.display = 'none';
		}
		return Promise.resolve(true);
	},

	setControlsAsReadonly:function() {
		let inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
		let selects = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-select');
		let lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');
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


 /*validateControl:function(ctl, id, dtId, ndtID) {
	if (ctl) {
		d=new Date(document.getElementById(dtId).value);
		dt=d.getDate();
		mn=d.getMonth();
		mn++;
		yy=d.getFullYear();
		document.getElementById(ndtID).value=dt+"/"+mn+"/"+yy
		document.getElementById(ndtID).hidden=false;
		document.getElementById(dtId).hidden=true;
		let icon = document.getElementById(id);
		if(icon) {
			if (ctl.value) {
				icon.style.display = 'none';
			} else {
				icon.style.display = 'block';
			}
		}
	}
	
	
},*/
	validateControl:function(ctl, id) {
		if (ctl) {
			let icon = document.getElementById(id);
			if(icon) {
				if (ctl.value) {
					icon.style.display = 'none';
				} else {
					icon.style.display = 'block';
				}
			}
		}
	},
	closeAddressSearch:function() {
		let lp = document.getElementById('lookup-id-address-search');
		lp.classList.remove('slds-is-open');
	},

	closeContactSearch:function() { 
		let lp = document.getElementById('lookup-id-contact-search');
		lp.classList.remove('slds-is-open');
	},

	selectDeliveryAddress:function(element) {
		var ase = document.getElementById('combobox-id-da-search-field');
		ase.value = element.title;
		var ase = document.getElementById('combobox-id-da-search-field');
		ase.setAttribute('data-value', element.getAttribute('data-value'));
		ase.readOnly = true;
		document.getElementById('combobox-id-da-search-field-x').style.display='block';
		document.getElementById('combobox-id-da-search-field-info').style.display='none';
		OEAddressSearchPhraseNew = element.title;

		BulkUtils.closeAddressSearch();
	},
	tabForDeliveryDetails :function(){
		let isDeliveryStatus=false;
		for (let x = 0; x < OEConfigurationsNew.length; x++) {
			if(!OEConfigurationsNew[x].IsDeliveryDetailsEnriched){
				isDeliveryStatus=true;
			}
		}
		//let detabdel1 = document.getElementById('combobox-id-da-search-field-info').style.display;
		//let detabdel2 = document.getElementById('combobox-id-dc-search-field-info').style.display;
		let detabdel3 = document.getElementById('OEtab_1');
		let detabdel4 = document.getElementById('oe-tab-delivery__item');
		//if(detabdel1==='none' && detabdel2==='none'){
		if(!isDeliveryStatus){
			detabdel3.classList.remove('slds-is-error');
			detabdel3.classList.add('slds-is-complete');
			detabdel4.classList.remove('icon-warning');
			detabdel4.classList.add('icon-check');
		}else{
			detabdel3.classList.remove('slds-is-complete');
			detabdel3.classList.add('slds-is-error');
			detabdel4.classList.remove('icon-check');
			detabdel4.classList.add('icon-warning');
		}
	},
	TabForCRD : function (){
		let isCRDStatus=false;
		for (let x = 0; x < OEConfigurationsNew.length; x++) {
			if(!OEConfigurationsNew[x].IsCRdEnriched){
				isCRDStatus=true;
			}
		}
		
		//let iconForbeforCRD = document.getElementById('help-Not Before CRD').style.display;
		//let iconForPreferedCRD = document.getElementById('help-Preferred CRD').style.display;
		let iconForbeforCRDStatus = document.getElementById('oe-tab-CRD__item');
		let iconForPreferedCRDStatus = document.getElementById('OEtab_2');
		if(!isCRDStatus){
			iconForbeforCRDStatus.classList.remove('icon-warning');
			iconForbeforCRDStatus.classList.add('icon-check');
			iconForPreferedCRDStatus.classList.remove('slds-is-error');
			iconForPreferedCRDStatus.classList.add('slds-is-complete');
		}else{
			iconForbeforCRDStatus.classList.remove('icon-check');
			iconForbeforCRDStatus.classList.add('icon-warning');
			iconForPreferedCRDStatus.classList.remove('slds-is-complete');
			iconForPreferedCRDStatus.classList.add('slds-is-error');
		}
	},
	selectContact:function(element) {
		var ase = document.getElementById('combobox-id-dc-search-field');
		ase.value = element.title;
		ase.setAttribute('data-value', element.getAttribute('data-value'));
		ase.readOnly = true;
		document.getElementById('combobox-id-dc-search-field-x').style.display='block';
		document.getElementById('combobox-id-dc-search-field-info').style.display='none';
		OEContactSearchPhraseNew = element.title;
		BulkUtils.closeContactSearch();
	},

	clearSelectedAddress:function() {
		console.log('clearSelectedAddress');
		var ase = document.getElementById('combobox-id-da-search-field');
		ase.value = '';
		ase.setAttribute('data-value', '');
		ase.readOnly = false;
		document.getElementById('combobox-id-da-search-field-x').style.display='none';
		document.getElementById('combobox-id-da-search-field-info').style.display='block';
	},

	clearSelectedContact:function() {
		var ase = document.getElementById('combobox-id-dc-search-field');
		ase.value = '';
		ase.setAttribute('data-value', '');
		ase.readOnly = false;
		document.getElementById('combobox-id-dc-search-field-x').style.display='none';
		document.getElementById('combobox-id-dc-search-field-info').style.display='block';
	},

	configurationSearchKeyUp:async function(event) {
		var element = document.getElementById('configurationSearch');
		if (element) {
			if (event.key === 'Enter' || !element.value || element.value.length===0 || (element.value &&  element.value.length >=3)) {
				var container = document.getElementById('config_table_scrollable_container');
				container.innerHTML = await BulkUtils.createConfigTableRows(element.value);
			}
		}
		return Promise.resolve(true);
	},

	fetchConfigurations:async function() {
		OEConfigurationsNew=[];
		let solution = await CS.SM.getActiveSolution();
		//await CS.SM.getActiveSolution().then(function(solution) {
		if(solution.components && Object.values(solution.components).length > 0){
			//solution.components.forEach(function (component) {
			Object.values(solution.components).forEach(function (component) {
				if (component.name === bulkOEComponentNameNew) {
					if(component.schema.configurations && Object.values(component.schema.configurations).length > 0){
						Object.values(component.schema.configurations).forEach(function (config) {
							//var disconnectionDateAttribute = config.attributes.filter(a => {
							var disconnectionDateAttribute = Object.values(config.attributes).filter(a => {
								return a.name === 'DisconnectionDate'
							});
							var ActiveConfig=config.disabled;
							if ((!disconnectionDateAttribute || disconnectionDateAttribute.length === 0 || !disconnectionDateAttribute[0].showInUi)&& !ActiveConfig) {
								var row = {};
								row.guid = config.guid;

								let name = '';
								if (bulkOEComponentName === 'Mobility') {
									row.name = BulkUtils.getNameCwpMobility(config, config.name);
									row.modelName = BulkUtils.getModelNameCWP(config);
								} else {
									//row.name = BulkUtils.getNameEM(solution, config, config.name);
									row.name = BulkUtils.getNameEM(solution, config, config.name, retMapOE[config.id]); //EDGE-172941 INC000093743308 Fix
									row.modelName = BulkUtils.getModelNameEM(config);
									row.CustomerFacingServiceId=BulkUtils.getModelAttributeForEM(config,'CustomerFacingServiceId',false);
									row.SiteDeliveryContact=BulkUtils.getModelAttributeForEM(config, 'SiteDeliveryContact',false);
									row.SiteDeliveryAddress=BulkUtils.getModelAttributeForEM(config, 'SiteDeliveryAddress',false);
									row.NotBeforeCRD=BulkUtils.getModelAttributeForEM(config, 'Not Before CRD',false);
									row.PreferredCRD=BulkUtils.getModelAttributeForEM(config, 'Preferred CRD',false);
									row.Notes=BulkUtils.getModelAttributeForEM(config,'Notes',false);
									row.CallRestriction=BulkUtils.getModelAttributeForEM(config,'Call Restriction',false);
									row.INTROAM=BulkUtils.getModelAttributeForEM(config,'INTROAM',false);
									row.isDeliveryDetailsRequired=BulkUtils.getModelAttributeForEM(config,'isDeliveryDetailsRequired',false);
									row.isCRDDatesRequired=BulkUtils.getModelAttributeForEM(config,'isCRDDatesRequired',false);
									row.isFeaturesRequired=BulkUtils.getModelAttributeForEM(config,'isFeaturesRequired',false);
									row.isDeliveryEnrichmentNeededAtt=BulkUtils.getModelAttributeForEM(config,'isDeliveryEnrichmentNeededAtt',false);
									row.isCRDEnrichmentNeededAtt=BulkUtils.getModelAttributeForEM(config,'isCRDEnrichmentNeededAtt',false);
									if(row.SiteDeliveryContact && row.SiteDeliveryAddress && (!row.isDeliveryEnrichmentNeededAtt || row.isDeliveryEnrichmentNeededAtt==='false'))
										row.IsDeliveryDetailsEnriched=true;
									else
										row.IsDeliveryDetailsEnriched=false;
									
										//Added below check for EDGE-142321
									if ((row.isDeliveryEnrichmentNeededAtt==='false'|| !row.isDeliveryEnrichmentNeededAtt ) && (row.isDeliveryDetailsRequired  === 'false' || !row.isDeliveryDetailsRequired) )
									{
										console.log ('@@@@@@@@@@@Enrichment not needed ');
										row.IsDeliveryDetailsEnriched=true;
										
									}
									// End 142321 						
									if(row.NotBeforeCRD && row.PreferredCRD)
										row.IsCRdEnriched=true;
									else
										row.IsCRdEnriched=false;	
								}
								row.searchField = row.name + ' ' + row.modelName+''+row.CustomerFacingServiceId;
								row.orderEnrichmentList = config.orderEnrichmentList;
								OEConfigurationsNew.push(row);
							}

						});
					}
				}
			});
		}//});
		return Promise.resolve(true);
	},
	getModelAttributeForEM(config,attr,flag){
		let attrValue = '';
		//var attrName= config.attributes.filter(a => {return a.name===attr});
		var attrName= Object.values(config.attributes).filter(a => {return a.name===attr});
		if (!attrName || attrName.length === 0)
			return attrValue;
		if(!flag)
		attrValue = attrName[0].value;
		else{
		attrValue = attrName[0].displayValue;
		}
		return attrValue;
	},
	isOredrEnrichmentDoneForConfigurationStatus:function(OEConfigurationsList) {
		if (OEConfigurationsList.length>0)
			return true;
		else
			return false;
		/*loop1:
		for (let x = 0; x < OEConfigurationsList.length; x++) {
			for (let y = 0; y < OEConfigurationsList[x].orderEnrichmentList.length; y++) {
				let orderEnrichmentattrList=OEConfigurationsList[y].orderEnrichmentList;
				for (let z = 0; z < orderEnrichmentattrList.length; z++) {
					let attributeList=orderEnrichmentattrList[z].attributes;
					for (let A = 0; A < attributeList.length; A++) {
						if(attributeList[A].name==='DeliveryContact' && (attributeList[A].value===null || attributeList[A].value==='')){
							isStatus=true;
							break loop1;
						}
						if(attributeList[A].name==='DeliveryAddress' && (attributeList[A].value===null || attributeList[A].value==='')){
							isStatus=true;
							break loop1;
						}
						if(attributeList[A].name==='Not Before CRD' && (attributeList[A].value===null || attributeList[A].value==='')){
							isStatus=true;
							break loop1;
						}
						if(attributeList[A].name==='Preferred CRD' && (attributeList[A].value===null || attributeList[A].value==='')){
							isStatus=true;
							break loop1;
						}
					}
					
				}
			}
		}*/
		return isStatus;
	},
	isOredrEnrichmentDoneForConfiguration:function(orderEnrichmentList) {
		if (!orderEnrichmentList)
			return false;
		let notEnriched = orderEnrichmentList.filter((oe) => {
			let emptyAttribute = Object.values(oe.attributes).filter(a => {return a.required &&  !a.value});
			return emptyAttribute && emptyAttribute.length > 0;
		});

		if (notEnriched && notEnriched.length > 0)
			return false;
		return true;
	},

	getModelNameCWP:function(config) {
		let modelName = '';
		if (config.relatedProductList && config.relatedProductList.length > 0) {
			config.relatedProductList.forEach((relatedConfig) => {
				if (relatedConfig.name === 'Mobile Device' && relatedConfig.type === 'Related Component' ) {
					if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
						var modelAtt = Object.values(relatedConfig.configuration.attributes).filter(a => {
							return a.name === 'MobileHandsetModel' && a.displayValue
						});
					}
					if (modelAtt && modelAtt.length > 0 ) {
						if (modelName.length>0)
							modelName += ', ';

						modelName =  modelName + modelAtt[0].displayValue;
					}
				}
			});
		}

		if (!modelName)
			return '-';

		return modelName;
	},

	getModelNameEM:function(config) {
		let modelName = '';
		if (config.relatedProductList && config.relatedProductList.length > 0) {
			config.relatedProductList.forEach((relatedConfig) => {
				if (relatedConfig.name === 'Device' && relatedConfig.type === 'Related Component' ) {
					if(relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0){
						var modelAtt = Object.values(relatedConfig.configuration.attributes).filter(a => {
							return a.name === 'MobileHandsetModel' && a.displayValue
						});
						var ChangeTypeDeviceAttr = Object.values(relatedConfig.configuration.attributes).filter(a => {
							return a.name === 'ChangeTypeDevice' 
						});
					}	
					if (modelAtt && modelAtt.length > 0 && ChangeTypeDeviceAttr[0].value !== 'PayOut' && ChangeTypeDeviceAttr[0].value !== 'PaidOut') {
						if (modelName.length>0)
							modelName += ', ';

						modelName = modelName +  modelAtt[0].displayValue;
					}
				}
			});
		}
		if (!modelName)
			return '-';

		return modelName;
	},

	getNameEM:function(solution, config, defaultName, oeNumber) { //EDGE-172941 INC000093743308 Fix - Added oeNumber parameter
		let name = defaultName;
		//if (!solution.schema.configurations || solution.schema.configurations.length === 0)
		if (!solution.schema.configurations || Object.values(solution.schema.configurations).length === 0)
			return name;

		//let cmpConfig = solution.schema.configurations[0];
		let cmpConfig = Object.values(solution.schema.configurations)[0];

		//var offerType= cmpConfig.attributes.filter(a => {return a.name==='OfferType'});
		var offerType= Object.values(cmpConfig.attributes).filter(a => {return a.name==='OfferType'});
		if (!offerType || offerType.length === 0)
			return name;

		name = offerType[0].displayValue;

		//var planType = config.attributes.filter(a => {return a.name==='SelectPlanType'});
		var planType = Object.values(config.attributes).filter(a => {return a.name==='SelectPlanType'});

		if (planType && planType.length > 0)
			name = name + ' - ' + planType[0].displayValue;

		//var plan =  config.attributes.filter(a => {return a.name==='Select Plan'});
		var plan =  Object.values(config.attributes).filter(a => {return a.name==='Select Plan'});

		if (plan && plan.length > 0)
			name = name + ' - ' + plan[0].displayValue;

		//EDGE-172941 INC000093743308 Fix Start	
		if((config && config.id !='' && config.id !=undefined && config.id !=null) &&(oeNumber && oeNumber!='' && oeNumber !=undefined && oeNumber !=null)){ // INC000093907636 Fix
				name = name + '-' + oeNumber;						
		}
		//EDGE-172941 INC000093743308 Fix End
		
		return name;
	},

	getNameCwpMobility:function(config, defaultName) {
		let mobilityaName = defaultName;

		//var mpAtt = config.attributes.filter((attr) => {
		var mpAtt = Object.values(config.attributes).filter((attr) => {
			return attr.name === 'MobilityPlan' && attr.displayValue
		});
		if (mpAtt && mpAtt.length > 0) {
			mobilityaName = mpAtt[0].displayValue;
		}
		return mobilityaName;
	},

	setActive:function(elem) {
		//console.log("setActive: ", elem);
		BulkUtils.persistValuesForCurrentTab();
		if(elem.title=== 'Delivery Details'){		
			BulkUtils.updateSelectAll('No');
			BulkUtils.showOnlyDeliveryConfiguration();
		}
		if(elem.title==='Customer Requested Dates'){
			BulkUtils.updateSelectAll('No');
			BulkUtils.showOnlyCRDConfiguration();
		}
		if(elem.title==='Features'){
			BulkUtils.updateSelectAll('No');
			BulkUtils.showOnlyFeatureConfiguration();
		}
		document.getElementById('errorPannel').innerHTML = '';
		let mainDiv = document.getElementById('main-nav-div-1');
		let tabs = mainDiv.getElementsByClassName('slds-path__item');
		for (let i = 0; i < tabs.length; i++) {
			tabs[i].classList.remove('slds-is-active');
		}
		let links = mainDiv.getElementsByClassName('slds-path__link');
		for (let i = 0; i < links.length; i++) {

			links[i].setAttribute('aria-selected', false);
			links[i].setAttribute('tabindex', '-1')
			let tabId = links[i].getAttribute('aria-controls');
			if (tabId) {
				document.getElementById(tabId).classList.add('slds-hide');
				document.getElementById(tabId).classList.remove('slds-show');
			}

		}
		elem.classList.add('slds-is-active');
		elem.getElementsByClassName('slds-path__link')[0].setAttribute('aria-selected', true);
		elem.getElementsByClassName('slds-path__link')[0].setAttribute('tabindex', '0')

		var tabId = elem.getElementsByClassName('slds-path__link')[0].getAttribute('aria-controls');
		document.getElementById(tabId).classList.add('slds-show');
		document.getElementById(tabId).classList.remove('slds-hide');
		
		let tableValuePopulateActive= BulkUtils.isOredrEnrichmentDoneForConfigurationStatus(OEConfigurationsNew);
		if(tableValuePopulateActive){
			BulkUtils.drawOETabs(); 
		}

		if (isReadOnlyModeNew)
			BulkUtils.setControlsAsReadonly();
	},

	drawOETabs:function() {
		BulkUtils.drawOETable(crdHtmlNew,'crd_oe');
		BulkUtils.drawDeliveryDetails('delivery_oe');
		BulkUtils.drawOETable(mfHtmlNew,'features_oe');
	},

	//doAddressSearch:function() {
	doAddressSearch:async function() {
		let currentBasket = await CS.SM.getActiveBasket();
		if (isReadOnlyModeNew)
			return;

		BulkUtils.closeContactSearch();
		var ase = document.getElementById('combobox-id-da-search-field');
		if (!ase || ase.readOnly)
			return;

		if (OEAddressSearchPhraseNew === ase.value && OEAddressSearchResultNew && OEAddressSearchResultNew.length > 0) {
			BulkUtils.populateAddressLookup(OEAddressSearchResultNew);
			return;
		}

		BulkUtils.showFetchingValuesLine(true);

		var input = {};
		//input["basketId"] = CS.SM.session.basketId;
		input["basketId"] = currentBasket.basketId;
		input["searchString"] = ase.value; //ase.value;
		input["option"] = 'addresses';
		console.log('doAddressSearch: ', ase.value);
		//CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function(values) {
		await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function(values) {
			OEAddressSearchPhraseNew = ase.value;
			OEAddressSearchResultNew = values.addresses;
			BulkUtils.populateAddressLookup(values.addresses);
			ase.focus();
		});
		return Promise.resolve(true);
	},

 	//doContactSearch:function() {
	doContactSearch:async function() {
		let currentBasket = await CS.SM.getActiveBasket();
		if (isReadOnlyModeNew)
			return;
		BulkUtils.closeAddressSearch();

		var cse = document.getElementById('combobox-id-dc-search-field');
		if (!cse || cse.readOnly)
			return;

		if (OEContactSearchPhraseNew === cse.value && OEContactSearchResultNew && OEContactSearchResultNew.length>0) {
			BulkUtils.populateContactLookup(OEContactSearchResultNew);
			return;
		}

		BulkUtils.showFetchingValuesLine(false);

		var input = {};
		//input["basketId"] = CS.SM.session.basketId;
		input["basketId"] = currentBasket.basketId;
		input["searchString"] = cse.value;
		input["option"] = 'contact';
		console.log('doContactSearch: ', cse.value);
		//CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function(values) {
		await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function(values) {
			OEContactSearchPhraseNew = cse.value;
			OEContactSearchResultNew = values.contact;
			BulkUtils.populateContactLookup(values.contact);
			cse.focus();
		});
		return Promise.resolve(true);
	},

	addressSearchKeyUp:function(event) {
		if (event.key === 'Enter') {
			BulkUtils.doAddressSearch();
		} else {
			if (OETimeoutAddressSearchNew)
				clearTimeout(OETimeoutAddressSearchNew);
			OETimeoutAddressSearchNew = setTimeout(BulkUtils.doAddressSearch, 500);
		}
	},

	contactSearchKeyUp:function(event) {
		if (event.key === 'Enter') {
			BulkUtils.doContactSearch();
		} else {
			if (OETimeoutContactSearchNew)
				clearTimeout(OETimeoutContactSearchNew);
			OETimeoutContactSearchNew = setTimeout(BulkUtils.doContactSearch, 500);
		}
	},

	createDeliveryAddressObjects:function(addresses) {
		deliveryDetailsAddressHtmlNew = '';
		deliveryDetailsAddressHtmlNew += '<div class="slds-form-element">'
		+ '<label class="slds-form-element__label" for="combobox-id-da-search-field">Delivery Address</label>'
		+'<div class="slds-form-element__control" >'
		+	'<div class="slds-combobox_container">'
		+	'<div class="slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click" id = "lookup-id-address-search" aria-expanded="false" aria-haspopup="listbox" role="combobox">'
		+	'<div class="slds-combobox__form-element slds-is-relative" role="none">'
		+	'<input type="text" class="inpt-lookup slds-input slds-combobox__input" id="combobox-id-da-search-field" attName="DeliveryAddress" data-value="" aria-autocomplete="list" aria-controls="combobox-id-da-search-field" autoComplete="off" role="textbox" placeholder="Search..."  onkeyup="BulkUtils.addressSearchKeyUp(event)"  onfocus="BulkUtils.doAddressSearch()"/>';

		if (!isReadOnlyModeNew) {
			deliveryDetailsAddressHtmlNew+= '<div class="tooltip icon-info ng-star-inserted" id="combobox-id-da-search-field-info" style="position:absolute; right: 10px;">'
			+ 	'<span class="tooltip-arrow"></span>'
			+ 	'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>'
			+ '</div>'
			+'<span class="icon-close slds-float_right" onclick="BulkUtils.clearSelectedAddress()" id="combobox-id-da-search-field-x" style="position:absolute; top:35%; right:10px; display: none"/>';
		}

		deliveryDetailsAddressHtmlNew+= '</div>'
			+	'<div id="listbox-id-address-search" class="slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid" role="listbox">';

		deliveryDetailsAddressHtmlNew+= BulkUtils.getAddressLookupResultList(OEAddressSearchResultNew);
		deliveryDetailsAddressHtmlNew+= '</div>'
		+'	</div>'
		+'  <div>Update Delivery Address if Applicable</div>'
		+'	</div>'
		+'	</div>'
		+'	</div>';

	},

	populateAddressLookup:function(records) {

		let lb = document.getElementById('listbox-id-address-search');
		let lp = document.getElementById('lookup-id-address-search');

		lb.innerHTML = '';
		if (records && records.length > 0) {
			lb.innerHTML = BulkUtils.getAddressLookupResultList(records);
			lp.classList.add('slds-is-open');
		}else {
			lb.innerHTML = BulkUtils.getNoDataLine();
			if (OETimeoutNoDataNew)
				clearTimeout(OETimeoutNoDataNew);
			OETimeoutNoDataNew = setTimeout(() => {lp.classList.remove('slds-is-open');},2000);
		}
	},

	getAddressLookupResultList:function(records) {
		var control = '';
		if (records && records.length > 0) {
			control = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">';
			for (let j = 0; j < records.length; j++) {
				let val = JSON.stringify(records[j]);
				control +=
					'<li role="presentation" class="slds-listbox__item">'
					+ '<div id="option-da-' + j + '" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" title="' + records[j].Name + '" role="option"  onclick="BulkUtils.selectDeliveryAddress(this)"'
					+ "data-value='" + val + "'"
					+ '>'
					+ '<span class="slds-media__body">'
					+ '<span  class="slds-truncate">' +  records[j].Address_ID__c + ' | ' + records[j].Name + ' | ' + records[j].Address_Status__c + '</span>'
					+ '</span>'
					+ '	</div>'
					+ '</li>';
			}
			control += '</ul>';
		}
		return control;
	},

	createDeliveryContactObjects:function(contact) {
		deliveryDetailsContactHtmlNew = '</br>';

		deliveryDetailsContactHtmlNew += '<div class="slds-form-element">'
			+ '<label class="slds-form-element__label" for="combobox-id-dc-search-field">Delivery Contact</label>'
			+'<div class="slds-form-element__control" >'
			+	'<div class="slds-combobox_container">'
			+	'<div class="slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click" id = "lookup-id-contact-search" aria-expanded="false" aria-haspopup="listbox" role="combobox">'
			+	'<div class="slds-combobox__form-element slds-is-relative" role="none">'
			+	'<input type="text" class="inpt-lookup slds-input slds-combobox__input" id="combobox-id-dc-search-field" attName="DeliveryContact" data-value="" aria-autocomplete="list" aria-controls="combobox-id-dc-search-field" autoComplete="off" role="textbox" placeholder="Search..."  onkeyup="BulkUtils.contactSearchKeyUp(event)"  onfocus="BulkUtils.doContactSearch()"/>';

		if (!isReadOnlyModeNew) {
			deliveryDetailsContactHtmlNew+= '<div class="tooltip icon-info" id="combobox-id-dc-search-field-info"  style="position:absolute; right: 10px;>'
			+ 		'<span class="tooltip-arrow"></span>'
			+ 		'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>'
			+ 	'</div>'
			+ '<span class="icon-close " onclick="BulkUtils.clearSelectedContact()" id="combobox-id-dc-search-field-x" style="position:absolute; top:35%; right: 10px; display: none" />';
		}

		deliveryDetailsContactHtmlNew+='</div>'
			+	'<div id="listbox-id-contact-search" class="slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid"  role="listbox">';

		deliveryDetailsContactHtmlNew+= BulkUtils.getContactLookupResultList(OEContactSearchResultNew);
		deliveryDetailsContactHtmlNew+= '</div>'
			+'	</div>'
			+'	<div>Update Delivery Contact if Applicable</div>'
			+'	</div>'
			+'	</div>'
			+'	</div>';
	},

	populateContactLookup:function(records) {

		let lb = document.getElementById('listbox-id-contact-search');
		let lp = document.getElementById('lookup-id-contact-search');

		lb.innerHTML = '';
		if (records && records.length > 0) {
			lb.innerHTML = BulkUtils.getContactLookupResultList(records);
			lp.classList.add('slds-is-open');
		} else {
			lb.innerHTML = BulkUtils.getNoDataLine();
			if (OETimeoutNoDataNew)
				clearTimeout(OETimeoutNoDataNew);
			OETimeoutNoDataNew = setTimeout(() => {lp.classList.remove('slds-is-open');},2000);
		}
	},

	getContactLookupResultList:function(records) {
		var control = '';
		if (records && records.length > 0) {
			control = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">';
			for (let j = 0; j < records.length; j++) {
				let val = JSON.stringify(records[j]);
				control +=
					'<li role="presentation" class="slds-listbox__item">'
					+ '<div id="option-dc-' + j + '" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" title="' + records[j].Name + '" role="option" onclick="BulkUtils.selectContact(this)"'
					+ "data-value='" + val + "'"
					+ '>'
					+ '<span class="slds-media__body">'

					+ '<span  class="slds-truncate" >'  + records[j].Name;

					if (records[j].Email){
						control += " | " + records[j].Email ;
					} else {
						control += " | -" ;
					}

					if (records[j].Phone){
						control += " | " + records[j].Phone ;
					} else {
						control += " | -" ;
					}

					if (records[j].MobilePhone){
						control += " | " + records[j].MobilePhone ;
					} else {
						control += " | -" ;
					}

				control+= '</span>'
					+ '</span>'
					+ '	</div>'
					+ '</li>';
			}
			control += '</ul>';
		}
		return control;
	},

	showFetchingValuesLine:function(isAddresSearch) {
		if (OETimeoutNoDataNew)
			clearTimeout(OETimeoutNoDataNew);

		let line = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">'
			+ '<li role="presentation" class="slds-listbox__item">'
			+ '<div id="option-fetching-values" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" role="option" >'
			+ '<span class="slds-media__body">'
			+ '<span  class="slds-truncate">Fetching values... </span>'
			+ '</span>'
			+ '	</div>'
			+ '</li>'
			+ '</ul>';
		if(isAddresSearch) {
			let lb = document.getElementById('listbox-id-address-search');
			let lp = document.getElementById('lookup-id-address-search');
			lb.innerHTML = line;
			lp.classList.add('slds-is-open');
		} else {
			let lb = document.getElementById('listbox-id-contact-search');
			let lp = document.getElementById('lookup-id-contact-search');
			lb.innerHTML = line;
			lp.classList.add('slds-is-open');
		}
	},

	getNoDataLine:function() {
		return '<ul class="slds-listbox slds-listbox_vertical" role="presentation">'
			+ '<li role="presentation" class="slds-listbox__item">'
			+ '<div id="option-fetching-values" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" role="option" >'
			+ '<span class="slds-media__body">'
			+ '<span  class="slds-truncate">No data</span>'
			+ '</span>'
			+ '	</div>'
			+ '</li>'
			+ '</ul>';
	},

	prepareDeliveryDetails:function() {
		BulkUtils.createDeliveryAddressObjects();
		BulkUtils.createDeliveryContactObjects();
		BulkUtils.drawDeliveryDetails('delivery_oe');
	},

	drawDeliveryDetails:function(oeId) {
		BulkUtils.persistValuesForCurrentTab();
		deliveryDetailsHtmlNew = deliveryDetailsAddressHtmlNew + deliveryDetailsContactHtmlNew;
		var el = document.getElementById(oeId);
		if (el)
			el.innerHTML = deliveryDetailsHtmlNew.trim();
		BulkUtils.restoreValuesForCurrentTab();
	},
	drawNoupdateRequiredDetails:function(oeId) {
		deliveryDetailsHtmlNew = 'No Update Required';
		var el = document.getElementById(oeId);
		if (el)
			el.innerHTML = deliveryDetailsHtmlNew.trim();
	},

	prepareOETable:async function(oeName) {
		let grid = '';
		let CheckFlag=true;
		console.log('prepareOETable >>> ' );
		let oe = await BulkUtils.getOEAttributes(oeName);
		//await BulkUtils.getOEAttributes(oeName).then(function(oe) {
		if(oe) {
			Object.values(oe.schema.attributes).forEach(function(attr) {
				if (attr.showInUi) {
					let helpIconId;
					if (attr.type === 'String') {
						grid += '<div>';
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' +
							'<span>' + attr.label + '</span>';
						if (attr.required && !isReadOnlyModeNew) {
							grid += tooltipElementNew;
						}
						grid+='</label>' +
							'<div class="slds-form-element__control">' +
							'<textarea class="inpt" type="text" attName="' + attr.name +'"'+ 'class="slds-input">' + attr.value + '</textarea>' +
							'</div>' +
							'</div>';
						grid += '</div>';
					} else if (attr.type === 'Boolean') {
						grid +='<div><strong>You may choose to modify these features</strong></div>'
						grid += '<div>';
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' +
							'<span>' + attr.label + '</span>';
						if (attr.required && !isReadOnlyModeNew) {
							grid += tooltipElementNew;
						}
						grid +=	'</label>' +
							'<div class="slds-form-element__control">' +
							'<input attName="' + attr.name + '" class="inpt" type="checkbox" id="checkbox-' + attr.name + '" value="' + attr.value + '"' +
							'class="slds-input"/>' +
							'</div>' +
							'</div>';
						grid += '</div>';
					}else if (attr.type === 'Date') {
						if(CheckFlag){
						CheckFlag=false;	
						grid +='<div><strong>Request for delivery or installation</strong></div>'
						}
						grid += '<div>';
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' +
							'<span>' + attr.label + '</span>';

						if (attr.required && !isReadOnlyModeNew) {
							//grid += tooltipElementNew;
							helpIconId = 'help-' + attr.name;
							grid += '<div class="tooltip icon-info" id="' + helpIconId + '"  style="position:absolute; top:-3px; right:-20px;">'
							+ '<span class="tooltip-arrow"></span>'
							+ '<span class="slds-form-element__help tooltip-text">This value can not be empty</span>'
							+ '</div>';
						}

						grid +='</label>'+
							'<div class="slds-form-element__control">' +
							'<input  attName="' + attr.name + '" class="inpt" type="date" value="' + attr.value + '" id="input-' + attr.name + '"'  ;

							if (attr.required) {
								grid += ' onchange="BulkUtils.validateControl(this , \'' +  helpIconId + '\')"  ';
							}

						grid += 'class="slds-input" />' ;
						grid += '</div>' ;
						if(helpIconId==='help-Not Before CRD'){
						grid+='<div>Customer will not be ready before this date for delivery or installation</div>'	;
						}
						if(helpIconId==='help-Preferred CRD'){
						grid+='<div>Customer'+'\''+'s preferred date of delivery or installation</div>';
						}					
						grid+= '</div>';
						grid += '</div>';
					} else if (attr.type === 'Picklist') {
						var value = attr.value;
						grid += '<div>';
						grid += '<div class="slds-form-element">';
						grid += '<label class="slds-form-element__label">' +
							'<span>' + attr.label + '</span>';

						if (attr.required && !isReadOnlyModeNew) {
							grid += tooltipElementNew;
						}
						grid +=	'</label>' +
							'<div class="slds-form-element__control">' +
							'<select attName="' + attr.name + '" class="inpt-select" class="slds-select" data-id="' + attr.name +  '">';
						for (var j = 0; j < attr.options.length; j++) {
							if (attr.options[j] == value) {
								grid += '<option value="' + attr.options[j] + '" selected>' + attr.options[j] + '</option>';
							} else {
								grid += '<option value="' + attr.options[j] + '">' + attr.options[j] + '</option>';
							}
						}
						grid += '</select>' +
							'</div>' +
							'  Call restrictions do not apply to data plans.</div>'; //EDGE-154371 Changes
						grid += '</div>';
					}

				}
			});
		//});
		}
		
		// return grid.trim();
		return Promise.resolve(grid.trim());
	},

	drawOETable:function(tableHtml, oeId) {

		document.getElementById(oeId).innerHTML = tableHtml;
		BulkUtils.restoreValuesForCurrentTab();
	},

	getOEAttributes:async function(oeName) {
		let solution = await CS.SM.getActiveSolution();
		//return CS.SM.getActiveSolution().then(function(solution) {
		//return function(solution) {
			var retVal;
			if(solution.components){
				//solution.components.forEach(function(comp) {
				Object.values(solution.components).forEach(function(comp) {
					if (comp.name === bulkOEComponentNameNew) {
						if(comp.orderEnrichments){
							//comp.orderEnrichments.forEach(function(oe) {
							console.log("BulkEnrichmentNew :: getOEAttributes :: " , comp.orderEnrichments);
							Object.values(comp.orderEnrichments).forEach(function(oe) {							
								if (oe.name === oeName) {
									retVal = oe;
								}
							});
						}
					}
				});
			}
			//console.log('getOEAttributes: ', oeName, retVal );
			//return retVal;
			return Promise.resolve(retVal);
		//}
	},

	markSelection:function(ev, el) {

		ev.stopPropagation();

		var row = Utils.getClosestParent(el, 'tr');
		if (el.checked ) {
			row.classList.add('slds-is-selected');
			row.setAttribute('aria-selected', true);
		}
		else {
			row.classList.remove('slds-is-selected');
			row.setAttribute('aria-selected', false);
		}
	},

	updateSelectAll:function(flag) {
		var SelctionVar='';
		var selectAll;
		var isActiveTab = document.getElementsByClassName('slds-is-active');
		var tesxva=isActiveTab[3].innerText;
		var isEnaableConfig = document.getElementsByClassName('slds-hint-parent slds-hide'); //EDGE-147597 added by ankit
		
		if(tesxva==='Delivery Details'){
			SelctionVar='DeliveryTab';
		}else if(tesxva==='Customer Requested Dates'){
			SelctionVar='CRDTab';
		}else if(tesxva==='Features'){
			SelctionVar='FeatureTab';
		}
		var selections = document.getElementsByClassName('pc-selection');
		if(flag==='Yes'){
			selectAll = document.getElementById('checkboxAll');
		}else if(flag==='No'){
			selectAll = document.getElementById('checkboxAll');
			selectAll.checked =false;
		}
	
		for (var i = 0; i < selections.length; i++) {
			//EDGE-147597 added by ankit || start
			var IsSelect=true;
			for(var x = 0; x < isEnaableConfig.length; x++){
				var guidConfig=isEnaableConfig[x].getAttribute('data-value');
				if(selections[i].defaultValue===guidConfig && isEnaableConfig[x].id.includes(SelctionVar)){
					IsSelect=false;
				}
			}
			//EDGE-147597 added by ankit || End
			if(selections[i].id.includes(SelctionVar) && IsSelect){ //EDGE-147597 added by ankit IsSelect
				selections[i].checked = selectAll.checked
				var row = Utils.getClosestParent(selections[i], 'tr');
				if (selections[i].checked ) {
					row.classList.add('slds-is-selected');
					row.setAttribute('aria-selected', true);
				}
				else {
					row.classList.remove('slds-is-selected');
					row.setAttribute('aria-selected', false);
				}
			}
				
		}
		
	},

	getSelectedConfigurations:function() {
		let selections = document.getElementsByClassName('pc-selection');
		let configIds = [];
		for (let i = 0; i < selections.length; i++) {
			if (selections[i].checked && !configIds.contains(selections[i].getAttribute('value'))) {
				configIds.push(selections[i].getAttribute('value'));
			}
		}
		console.log('getSelectedConfigurations:', configIds);
		return configIds;
	},
	getSelectedConfigurationsTabName:function() {
		let selections = document.getElementsByClassName('pc-selection');
		let tabName = {};
		for (let i = 0; i < selections.length; i++) {
			if (selections[i].checked) {
				tabName[selections[i].id]=selections[i].getAttribute('value')
			}
		}
		console.log('getSelectedConfigurationsTabName:', tabName);
		return tabName;
	},

populateSchemaIds:async function() {
	OESchemaIdMapNew = {};
	let solution = await CS.SM.getActiveSolution();
	if(solution.components){
		Object.values(solution.components).forEach(function (comp) {
			if (comp.name === bulkOEComponentNameNew) {
				if(comp.orderEnrichments){
					Object.values(comp.orderEnrichments).forEach(function (oe) {
						OESchemaIdMapNew[oe.name] = oe.id;
					});
				}
			}
		});
	}
	return Promise.resolve(true);
},

	/*populateSchemaIds:async function() {
		OESchemaIdMapNew = [];
		let solution = await CS.SM.getActiveSolution();
		if(solution.components){
			Object.values(solution.components).forEach(function (comp) {
				if (comp.name === bulkOEComponentNameNew) {
					Object.values(comp.schema.configurations).forEach((config) => {
						Object.values(comp.orderEnrichments).forEach(function (oeSchema) {
							if ( !config.orderEnrichments ||  !config.orderEnrichments[oeSchema.id]) {
								//OESchemaIdMapNew[oe.name] = oe.id;
								let el = {};
								el.componentName = comp.name;
								el.configGuid = config.guid;
								el.oeSchema = oeSchema;
								OESchemaIdMapNew.push(el);
							}
						});
					});
				}
			});
		}
		return Promise.resolve(true);
	},*/

	getAttributeMap:function() {

		if (isReadOnlyModeNew)
			return;
		/*var inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
		var lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');

		var attributeMap = [];
		var attrs = {};
		for (var i = 0; i < inputs.length; i++) {
			var type = inputs[i].getAttribute('type');
			if (type && type === 'checkbox') {
				attrs[inputs[i].getAttribute('attName')] = inputs[i].checked ? 'Yes' : 'No';
			} else {
				attrs[inputs[i].getAttribute('attName')] = inputs[i].value;
			}
		}*/
												
		var inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
		var lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');
		var inputselect = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-select');
		var allItems = [];
		allItems = Array.prototype.concat.apply(allItems,inputs);
		allItems = Array.prototype.concat.apply(allItems,inputselect);
		var attributeMap = [];
		var attrs = {};
		for (let i = 0; i < allItems.length; i++) {
			var type = allItems[i].getAttribute('type');
			if (type && type === 'checkbox') {
				attrs[allItems[i].getAttribute('attName')] = allItems[i].checked ? 'Yes' : 'No';
			} else {
				attrs[allItems[i].getAttribute('attName')] = allItems[i].value;
			}
		}             


		for (let i = 0; i < lookups.length; i++) {
			var attName = lookups[i].getAttribute('attName');
			if (attName.includes('DeliveryContact')) {
			//	console.log('DeliveryContact: ',lookups[i].getAttribute('data-value'))
				var parsedData = lookups[i].getAttribute('data-value') ? JSON.parse(lookups[i].getAttribute('data-value')) : {};
				attrs['DeliveryContact'] = parsedData.Id ? parsedData.Id : '';
				attrs['Name'] = parsedData.Name ? parsedData.Name : '';
				attrs['FirstName'] = parsedData.FirstName? parsedData.FirstName : '';
				attrs['LastName'] = parsedData.LastName? parsedData.LastName : '';
				attrs['Phone'] = parsedData.Phone? parsedData.Phone : '';
				attrs['Mobile'] = parsedData.MobilePhone ? parsedData.MobilePhone : '';
				attrs['Email'] = parsedData.Email ? parsedData.Email : '';
				attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;
			} else if (attName.includes('DeliveryAddress')) {
			//	console.log('DeliveryAddress: ',lookups[i].getAttribute('data-value'))
				var parsedData = lookups[i].getAttribute('data-value') ? JSON.parse(lookups[i].getAttribute('data-value')) : {};
				attrs['DeliveryAddress'] = parsedData.Id ? parsedData.Id : '';
				attrs['ADBOIRId'] = parsedData.Address_ID__c ? parsedData.Address_ID__c  : '';
				attrs['Postcode'] = parsedData.cscrm__Zip_Postal_Code__c ? parsedData.cscrm__Zip_Postal_Code__c : '';
				attrs['Street'] = parsedData.Street_calc__c ? parsedData.Street_calc__c : '';
				attrs['Address'] = parsedData.Name ? parsedData.Name  : '';
				attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;
			} else {
				attrs[attName] = JSON.parse(lookups[i].getAttribute('data-value'));
			}
		}
		attributeMap.push(attrs);
		return attributeMap;
	},

	persistValuesForCurrentTab:function() {
		if (isReadOnlyModeNew)
			return;
		let inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
		let selects = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-select');
		let lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');
		let i;
		let attName;
		for (let i = 0; i < inputs.length; i++) {
			var type = inputs[i].getAttribute('type');
			if (type && type === 'checkbox') {
				persistentValuesNew[inputs[i].getAttribute('attName')] = inputs[i].checked;
			}else{
				persistentValuesNew[inputs[i].getAttribute('attName')] = inputs[i].value;
			} 
		}

		for (let i = 0; i < selects.length; i++) {
			attName = selects[i].getAttribute('attName');
			persistentValuesNew[attName] = selects[i].value;
		}

		for (let i = 0; i < lookups.length; i++) {
			attName = lookups[i].getAttribute('attName');
			persistentValuesNew[attName] = lookups[i].getAttribute('data-value');
		}

		let links = document.getElementsByClassName('slds-path__link');
		for (let i = 0; i < links.length; i++) {
			if (links[i].getAttribute('aria-selected') === 'true') {
				allOeValuesNew[links[i].getAttribute('name')] = BulkUtils.getAttributeMap();
				break;
			}
		}

		console.log('persistentValuesNew' , persistentValuesNew);
	},

	restoreValuesForCurrentTab:function() {
		console.log('restoreValuesForCurrentTab',persistentValuesNew);

		let inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
		let selects = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-select');
		let lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');
		//let i;
		let attName;
		let helpIconId;
		let info;

		for (let i = 0; i < inputs.length; i++) {
			let type = inputs[i].getAttribute('type');

			if (type && type === 'checkbox') {
				if (persistentValuesNew[inputs[i].getAttribute('attName')]=== undefined) {
					inputs[i].checked =true;
				}else {
					inputs[i].checked =persistentValuesNew[inputs[i].getAttribute('attName')];

				}
			} else if (type && type === 'date') { ///EDge-EDGE-137466 start
				if (persistentValuesNew[inputs[i].getAttribute('attName')]) {
					inputs[i].value = persistentValuesNew[inputs[i].getAttribute('attName')];
				}/* else{
					var date = new Date();
					date.setDate(date.getDate() + 1);
					console.log('input id--->input-'+inputs[i].getAttribute('attName'));
					document.getElementById('input-'+inputs[i].getAttribute('attName')).value = date.toISOString().substring(0, 10);
					var d=new Date(document.getElementById('input-'+inputs[i].getAttribute('attName')).value);
					var dt=d.getDate();
					var mn=d.getMonth();
					mn++;
					var yy=d.getFullYear();
					document.getElementById('date-'+inputs[i].getAttribute('attName')).value=dt+"/"+mn+"/"+yy;
					document.getElementById('date-'+inputs[i].getAttribute('attName')).hidden=false;
					document.getElementById('input-'+inputs[i].getAttribute('attName')).hidden=true;
				}//EDGE-137466 end*/
			}else{
				if (persistentValuesNew[inputs[i].getAttribute('attName')]) {
					inputs[i].value = persistentValuesNew[inputs[i].getAttribute('attName')];
				}
			}

			if (persistentValuesNew[inputs[i].getAttribute('attName')]) {
				helpIconId = 'help-' + inputs[i].getAttribute('attName');
				info = document.getElementById(helpIconId);
				if (info) {
					info.style.display = 'none';
				}
			}
		}


		for (let i = 0; i < selects.length; i++) {
			attName = selects[i].getAttribute('attName');
			if (persistentValuesNew[attName]) {
				selects[i].value = persistentValuesNew[attName];
			}

			if (persistentValuesNew[attName]) {
				helpIconId = 'help-' + attName;
				info = document.getElementById(helpIconId);
				if (info) {
					info.style.display = 'none';
				}
			}
		}

		for (let i = 0; i < lookups.length; i++) {
			attName = lookups[i].getAttribute('attName');
			if (persistentValuesNew[attName]) {
				lookups[i].setAttribute('data-value', persistentValuesNew[attName]);

				if (!isReadOnlyModeNew) {
					lookups[i].value = JSON.parse(persistentValuesNew[attName]).Name;

					let xButton = document.getElementById(lookups[i].id + '-x');
					lookups[i].readOnly = true;
					xButton.style.display = 'block';
					console.log('insideif: ', lookups[i].value);
				}
				else {
					//Aditya Fixes EDGE-130398
					lookups[i].value = JSON.parse(persistentValuesNew[attName]).Name;
					// lookups[i].value = persistentValuesNew[attName];
					console.log('insideelse: ', lookups[i].value);
				}

				info = document.getElementById(lookups[i].id + '-info');
				if (info) {
					info.style.display='none';
				}
			} else {
				lookups[i].setAttribute('data-value', '');
				lookups[i].value = '';

				if (!isReadOnlyModeNew) {
					let xButton = document.getElementById(lookups[i].id + '-x');
					lookups[i].readOnly = false;
					xButton.style.display = 'none';
				}

				info = document.getElementById(lookups[i].id + '-info');
				if (info) {
					info.style.display='block';
				}
			}
		}
	// if(isMacdOreder)
		// ReadOnlyMobileFeature();
	},
	ReadOnlyMobileFeature:function(){
		
		var links = document.getElementsByClassName('slds-path__link');
		for (let  x = 0; x < links.length; x++) {
			selected = links[x].getAttribute('name');
			if(selected!==null && selected.toLowerCase() === 'Mobility features'.toLowerCase()){
				var selectedId = links[x].getAttribute('aria-controls');
				var inputsCheck= document.getElementById(selectedId).children[0].getElementsByClassName('inpt');
				let selectsList = document.getElementById(selectedId).children[0].getElementsByClassName('inpt-select');
				let lookupsValue = document.getElementById(selectedId).children[0].getElementsByClassName('inpt-lookup');
				// let j;
				// let k;
				// let L;
				for (let j = 0; j < inputsCheck.length; j++) {
					inputsCheck[j].setAttribute('disabled',true);
				}
				for (let k = 0; k < selectsList.length; k++) {
					selectsList[k].setAttribute('disabled',true);
				}
				for (let L = 0; L < lookupsValue.length; L++) {
					lookupsValue[L].setAttribute('disabled',true);
				}
			}
		}
	},
	closeOe:function() {
		//sessionStorage.setItem("close", "close");
		var el = document.getElementsByClassName('cdk-overlay-backdrop cdk-overlay-dark-backdrop cdk-overlay-backdrop-showing');
		if (el) {
			for (let i=0; i< el.length; i++) {
				el[i].click();
			}
		}
	},
	getAttributeDeliveryMap:async function() {
		
			if (lookups.includes('DeliveryContact')) {
			//	console.log('DeliveryContact: ',lookups[i].getAttribute('data-value'))
				var parsedData =  JSON.parse(lookups);
				attrs['DeliveryContact'] = parsedData.DeliveryContact ? parsedData.DeliveryContact : '';
				attrs['Name'] = parsedData.Name ? parsedData.Name : '';
				attrs['FirstName'] = parsedData.FirstName? parsedData.FirstName : '';
				attrs['LastName'] = parsedData.LastName? parsedData.LastName : '';
				attrs['Phone'] = parsedData.Phone? parsedData.Phone : '';
				attrs['Mobile'] = parsedData.MobilePhone ? parsedData.MobilePhone : '';
				attrs['Email'] = parsedData.Email ? parsedData.Email : '';
				attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;
			} else if (lookups.includes('DeliveryAddress')) {
			//	console.log('DeliveryAddress: ',lookups[i].getAttribute('data-value'))
				var parsedData =  JSON.parse(lookups);			
				attrs['DeliveryAddress'] = parsedData.DeliveryAddress ? parsedData.DeliveryAddress : '';
				attrs['ADBOIRId'] = parsedData.Address_ID__c ? parsedData.Address_ID__c  : '';
				attrs['Postcode'] = parsedData.cscrm__Zip_Postal_Code__c ? parsedData.cscrm__Zip_Postal_Code__c : '';
				attrs['Street'] = parsedData.Street_calc__c ? parsedData.Street_calc__c : '';
				attrs['Address'] = parsedData.Name ? parsedData.Name  : '';
				attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;
			} 
		
		attributeMap.push(attrs);
		//return attributeMap; 
		return Promise.resolve(attributeMap);
	},

	saveOEForSelectedConfigs:async function (closAfterSave) {
		try{
			let solution = await CS.SM.getActiveSolution();
			console.log('inside saveOEForSelectedConfigs');

			let spinner = document.getElementById('main-save-spinner-1');
			spinner.style.display = 'block';

			var attributeMap;
			var selectedConfigs;
			var selectedConfigTabName
			var isValid = false;
			var isCheckForDelTab = false;
			var isCheckForCRDTab = false;
			var isCheckForBothTab = false;
			BulkUtils.persistValuesForCurrentTab();

			selectedConfigs = BulkUtils.getSelectedConfigurations();
			selectedConfigTabName = BulkUtils.getSelectedConfigurationsTabName();
			console.log('selectedConfigTabName>>>>',selectedConfigTabName);
			if (selectedConfigTabName) {
					let tabNameGuid = Object.keys(selectedConfigTabName);	
				for (let i = 0; i < tabNameGuid.length; i++) {
					if(tabNameGuid[i].includes('DeliveryTab')){
						isCheckForDelTab = true;
					}else if(tabNameGuid[i].includes('CRDTab')){
						isCheckForCRDTab = true;
					}
					// Added by laxmi EDGE-147799 || start 
					else if(tabNameGuid[i].includes('FeatureTab')){ 
						isValid = true;
					}
					// Added by laxmi EDGE-147799 || End 
				}
			}
			if(isCheckForDelTab && isCheckForCRDTab){
				isValid = await BulkUtils.validateData('BothDetails');
			}else if(isCheckForDelTab && !isCheckForCRDTab){
				isValid = await BulkUtils.validateData('Delivery details');
			}else if(!isCheckForDelTab && isCheckForCRDTab){
				isValid = await BulkUtils.validateData('Customer requested Dates');
			}

			console.log('selectedConfigTabName--',selectedConfigTabName);
			if (isValid) {
				if(solution.components){
					for (let j=0; j<Object.values(solution.components).length; j++) {
						let comp = Object.values(solution.components)[j];
						if (comp.name === bulkOEComponentNameNew) {
							for (let k=0; k<Object.values(comp.schema.configurations).length; k++) {
								let config =Object.values(comp.schema.configurations)[k];
								if (selectedConfigs.contains(config.guid)) {
									var oldList = [];
									Object.keys(allOeValuesNew).forEach(key => {
										attributeMap = allOeValuesNew[key];
										if (config.orderEnrichmentList) {
											config.orderEnrichmentList.forEach((oe) => {
												//	console.log('Mobility oe: ', oe);
												var shouldDelete = true;
												if (attributeMap && attributeMap.length > 0) {
													for (var key in attributeMap[0]) {
														//	console.log('key: ', key);
														var a = Object.values(oe.attributes).filter(at => {
															return at.name === key
														});
														if (!a || a.length === 0)
															shouldDelete = false;
													}
												}
												if (shouldDelete)
													oldList.push(oe.guid);
											});
										}
									});
									if (oldList.length > 0) {
										console.log('Mobility deleteOrderEnrichments: ', oldList);
										//await CS.SM.deleteOrderEnrichments(bulkOEComponentNameNew, config.guid, oldList, true);
										for(let h = 0 ; h < oldList.length; h++){
											await comp.deleteOrderEnrichmentConfiguration(config.guid,oldList[h],true);
										}
									}
								}
							}
						}
					}
				}
			}
			var attrvalue=[];
			var updateTabMapForDel = {};
			var updateTabMapForCust = {};
			let currentBasket = await CS.SM.getActiveBasket();
			for (let i = 0; i < Object.values(OEConfigurationsNew).length; i++) {
				let row = OEConfigurationsNew[i];
				//EDGE-147597 added by ankit || start
				if(row.isDeliveryEnrichmentNeededAtt==='false' ||row.isDeliveryEnrichmentNeededAtt=== false){
				
					updateTabMapForDel[row.guid]=[];
					var attrs = {};
					var parsedData1Intial = row.SiteDeliveryContact;
					var parsedData1;
					if(parsedData1Intial!=null && parsedData1Intial!=''){
						if (parsedData1Intial) {
							let input = {};
							//input["basketId"] = CS.SM.session.basketId;
							input["basketId"] = currentBasket.basketId;
							input["searchString"] = parsedData1Intial;
							input["option"] = 'contact';
							//await CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
							await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
								if (values.contact && values.contact.length) {
									parsedData1= JSON.stringify(values.contact[0]);
								}
							});
						}
						if(parsedData1){
							var parsedDataDel =  JSON.parse(parsedData1);
							attrs['DeliveryContact'] = parsedData1Intial ? parsedData1Intial : '';
							attrs['Name'] = parsedDataDel.Name ? parsedDataDel.Name : '';
							attrs['FirstName'] = parsedDataDel.FirstName? parsedDataDel.FirstName : '';
							attrs['LastName'] = parsedDataDel.LastName? parsedDataDel.LastName : '';
							attrs['Phone'] = parsedDataDel.Phone? parsedDataDel.Phone : '';
							attrs['Mobile'] = parsedDataDel.MobilePhone ? parsedDataDel.MobilePhone : '';
							attrs['Email'] = parsedDataDel.Email ? parsedDataDel.Email : '';
							attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;	
						}
					}
					
					var parsedDataIntial2 = row.SiteDeliveryAddress;
					var parsedData2;
					if(parsedDataIntial2!=null && parsedDataIntial2!=''){
						if (parsedDataIntial2) {
						let input = {};
						//input["basketId"] = CS.SM.session.basketId;
						input["basketId"] = currentBasket.basketId;
						input["searchString"] = parsedDataIntial2;
						input["option"] = 'addresses';
							//await CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
								await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
								if (values.addresses && values.addresses.length) {
									parsedData2 = JSON.stringify(values.addresses[0]);
								}
							});
						}
						if(parsedData2){
							var parsedDataAdd =  JSON.parse(parsedData2);
							attrs['DeliveryAddress'] =parsedDataIntial2 ? parsedDataIntial2 : '';
							attrs['ADBOIRId'] = parsedDataAdd.ADBOIRId ? parsedDataAdd.ADBOIRId  : '';
							attrs['Postcode'] = parsedDataAdd.Postcode ? parsedDataAdd.Postcode : '';
							attrs['Street'] = parsedDataAdd.Street ? parsedDataAdd.Street : '';
							attrs['Address'] = parsedDataAdd.Address ? parsedDataAdd.Address  : '';
							attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;
						}
					}
					updateTabMapForDel[row.guid].push(attrs);
					
				}
				if(row.isCRDEnrichmentNeededAtt==='false' || row.isCRDEnrichmentNeededAtt===false){
					updateTabMapForCust[row.guid]=[];
					var attrscud = {};
					attrscud['Not Before CRD'] =row.NotBeforeCRD ? row.NotBeforeCRD : '';
					attrscud['Preferred CRD'] = row.PreferredCRD ? row.PreferredCRD  : '';
					attrscud['Notes'] = row.Notes ? row.Notes  : '';
					updateTabMapForCust[row.guid].push(attrscud);
				}
				//EDGE-147597 added by ankit || End
			}
			
			attributeMap={};
			updateTabMap = {};
			if (selectedConfigTabName && isValid) {
				let tabNameGuid = Object.keys(selectedConfigTabName);	
				for (let i = 0; i < tabNameGuid.length; i++) {
					let oeDataKeys = Object.keys(allOeValuesNew);
					if(!updateTabMap[selectedConfigTabName[tabNameGuid[i]]]){
						updateTabMap[selectedConfigTabName[tabNameGuid[i]]] = [];
						for (let l = 0; l<oeDataKeys.length; l++) {
							let key1 = oeDataKeys[l];
							attributeMap = allOeValuesNew[key1];
							if(updateTabMapForDel[selectedConfigTabName[tabNameGuid[i]]] && key1==='Delivery details' && !attributeMap[0]['DeliveryAddress']  && !attributeMap[0]['DeliveryContact']){
								attributeMap=updateTabMapForDel[selectedConfigTabName[tabNameGuid[i]]];
							}
							//EDGE-147597 added by ankit || start
							if(updateTabMapForCust[selectedConfigTabName[tabNameGuid[i]]] && key1==='Customer requested Dates' && !attributeMap[0]['Not Before CRD']  && !attributeMap[0]['Preferred CRD']){
								attributeMap=updateTabMapForCust[selectedConfigTabName[tabNameGuid[i]]];
							}
							//EDGE-147597 added by ankit || End

							// Arinjay Singh 15 July 2020 Start 
							let desiredComponent ;
							if (solution.components && Object.values(solution.components).length > 0) {
								//Object.values(solution.components).forEach((comp) => {
								for(let comp of Object.values(solution.components)){
									if(comp.orderEnrichments){
										//Object.values(comp.orderEnrichments).forEach((oeSchema) => {
										for(let oeSchema of Object.values(comp.orderEnrichments)){
											if (oeSchema.name.includes(key1)) {
												desiredComponent = oeSchema;
											}
										}
									}
								}
							}

							let attributeMap1 = allOeValuesNew[key1][0];
							let aData = [];
							
							for(let attrName in attributeMap1){
								aData.push({name:attrName,value: { value:attributeMap1[attrName], displayValue:attributeMap1[attrName]}});
							}

							let component = solution.findComponentsByConfiguration(selectedConfigTabName[tabNameGuid[i]]);
							let oeConfiguration = desiredComponent.createConfiguration(aData);
							await component.addOrderEnrichmentConfiguration(selectedConfigTabName[tabNameGuid[i]], oeConfiguration, false );

							// Arinjay Singh 15 July 2020 End
							validateOERules.MandateOESchemaOnAccepted();// Added by laxmi EDGE-147799
						}
					}	
					for (let l = 0; l<oeDataKeys.length; l++) {
						let key1 = oeDataKeys[l];
						attributeMap = allOeValuesNew[key1];
						
						if(attributeMap[0]['DeliveryAddress'] && attributeMap[0]['DeliveryContact'] && tabNameGuid[i].includes('DeliveryTab') ){
							BulkUtils.markConfigurationEnrichmentStatus(selectedConfigTabName[tabNameGuid[i]], true,'DeliveryTab');
						}
						else if(attributeMap[0]['Not Before CRD']  && attributeMap[0]['Preferred CRD'] && tabNameGuid[i].includes('CRDTab')){
							BulkUtils.markConfigurationEnrichmentStatus(selectedConfigTabName[tabNameGuid[i]], true,'CRDTab');
						}
					}
				}

				await BulkUtils.pushDataToParentConfigs(selectedConfigs,selectedConfigTabName);
				//await BulkUtils.pushDataToOrderEnrichmentConfigs(selectedConfigs);
				CS.SM.displayMessage('Selected configurations updated successfully!', 'success');
				if (closAfterSave) {
					BulkUtils.closeOe();
				} else {
					await BulkUtils.fetchConfigurations();
					BulkUtils.tabForDeliveryDetails();
					BulkUtils.TabForCRD();
				}

			} else {
				if (!isValid)
					CS.SM.displayMessage('Configuration is not saved!', 'error');
				else
					CS.SM.displayMessage('Select Mobility subscription(s)!', 'info');
			}
			spinner.style.display = 'none';
			return Promise.resolve(true);
		}
		catch(e){
			console.log('error',e);
			return Promise.resolve(true);
		}
	},

	/*Array.prototype.contains = function(obj) {
		var i = this.length;
		while (i--) {
			if (this[i] == obj) {
				return true;
			}
		}
		return false;
	},*/

	validateData:async function(tabName) {
		let currentBasket = await CS.SM.getActiveBasket();
		//console.log('validateData attributeMap ', attributeMap)
		var errorPanel = document.getElementById('errorPannel');
		var selected = '';
		var errorMessages = [];
		var links = document.getElementsByClassName('slds-path__link');
		for (let i = 0; i < links.length; i++) {
			selected = links[i].getAttribute('name');
			let attributeMap = allOeValuesNew[selected];

			if (attributeMap && attributeMap.length > 0) {
				if (selected.toLowerCase()=== 'Delivery details'.toLowerCase() && (selected.toLowerCase() === tabName.toLowerCase() || tabName.toLowerCase() === 'BothDetails'.toLowerCase() )) {
					console.log ('Delivery Contact',attributeMap[0]['DeliveryContact']);
					console.log ('Delivery Contact',attributeMap[0]);

					if (!attributeMap[0]['DeliveryContact']) {
						errorMessages.push('Delivery contact is not selected');
					}
					if (!attributeMap[0]['Email'] || !attributeMap[0]['Phone']  ) {
						errorMessages.push('Selected delivery contact does not have email id or phone number; Please update the contact details');
					}
					
				/*  else  {
							var InputMap = {};
							InputMap['DeliveryContact'] = attributeMap[0]['DeliveryContact'];
								await CS.SM.WebService.performRemoteAction('DeliveryEmailandPhoneNumberValidation', InputMap).then(result => {
									if (result && result != undefined) {
										if (result.errorMessage && result.errorMessage !== '') {
											console.log('Error Message ---->'+result.errorMessage);
											errorMessages.push(result.errorMessage);
										}
									}
								});
							}*/

					if (!attributeMap[0]['DeliveryAddress']) {
						errorMessages.push('Delivery address is not selected');
					}
				} else if (selected.toLowerCase()=== 'Customer requested Dates'.toLowerCase() && (selected.toLowerCase() === tabName.toLowerCase() || tabName.toLowerCase() === 'BothDetails'.toLowerCase())) {

					if (!attributeMap[0]['Not Before CRD']) {
						errorMessages.push('Not Before CRD is not populated');
					} else {
						var crd = new Date(attributeMap[0]['Not Before CRD']);
						var today = new Date();
						today.setHours(0, 0, 0, 0);
						crd.setHours(0, 0, 0, 0);
						if (crd < today) { //INC000093064228 remove eqaul sign by ankit
							errorMessages.push('Not Before CRD can not be less than Today');
						}
						console.log('bulkOEComponentNameNew result:', bulkOEComponentNameNew);
						if (bulkOEComponentNameNew == 'Mobility' || bulkOEComponentNameNew == 'Mobile Subscription') {
							//EDGE-92626
							//var basketId = CS.SM.session.basketId;
							var InputMap = {};
							InputMap['NotBefCRD'] = crd;
							//InputMap['basketId'] = basketId;
							InputMap['basketId'] = currentBasket.basketId;
							//console.log('InputMap:', InputMap);
							if (NotBefCRD = !null) {
								//await CS.SM.WebService.performRemoteAction('EnrichmentValidationRemoter', InputMap).then(result => {
								await currentBasket.performRemoteAction('EnrichmentValidationRemoter', InputMap).then(result => {
								//	console.log('EnrichmentValidationRemoter result:', result);
									if (result && result != undefined) {
										if (result.validationCRD && result.validationCRD === true) {
											errorPanel.innerHTML += 'Not Before CRD should be at least 15 days prior to the CA Expiry Date, please select a correct Not Before CRD or generate a new CA for customer sign off</BR>'
										//	console.log('EnrichmentValidationRemoter result:', result.validationCRD);
											errorMessages.push('Not Before CRD should be at least 15 days prior to the CA Expiry Date, please select a correct Not Before CRD or generate a new CA for customer sign off');
										}
									}
								});
							}
						}

					}

					if (!attributeMap[0]['Preferred CRD']) {
						errorMessages.push('Preferred CRD is not populated');
					} else {
						var ncrd = new Date(attributeMap[0]['Not Before CRD']);
						var crd = new Date(attributeMap[0]['Preferred CRD']);
						if (crd < ncrd) {
							errorMessages.push('Preferred CRD can not be set to date before Not Before CRD');
						}
					}

				}
			}
		}
		errorPanel.innerHTML = '';
		if (errorMessages.length > 0) {
			errorMessages.forEach(msg => {
				errorPanel.innerHTML += msg + '</BR>'
			});
			//return false;
			return Promise.resolve(false);
		}
		//return true;
		return Promise.resolve(true);
	},

	pushDataToParentConfigs: async function(selectedConfigs,selectedConfigTabName) {
		let currentSolution = await CS.SM.getActiveSolution();
		console.log('pushDataToParentConfigs');
		updateMap = {};
		var attMap = [];
		var attributeMap;
		Object.keys(allOeValuesNew).forEach(key => {
			attributeMap = allOeValuesNew[key];
			Object.keys(attributeMap[0]).forEach(key1 => {
				attMap[key1] = attributeMap[0][key1];
			});
		});
		let tabNameGuid = Object.keys(selectedConfigTabName);
		for (let i = 0; i < tabNameGuid.length; i++) {
			if(!updateMap[selectedConfigTabName[tabNameGuid[i]]])
			updateMap[selectedConfigTabName[tabNameGuid[i]]] = [];

			if( tabNameGuid[i].includes('DeliveryTab')){
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
					{
						name: 'isDeliveryEnrichmentNeededAtt',
						value: false
					});
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
					{
						name: 'SiteDeliveryContact',
						value: attMap['DeliveryContact'],
						displayValue: attMap['DeliveryContact']	
					});
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
					{
						name: 'SiteDeliveryAddress', 
						value: attMap['DeliveryAddress'],
						displayValue: attMap['DeliveryAddress']
					});
			}
			if( tabNameGuid[i].includes('CRDTab')){
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
				{
					name: 'isCRDEnrichmentNeededAtt',
					value: false
				});
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
				{
					name: 'Not Before CRD',
					value: attMap['Not Before CRD'],
					displayValue: attMap['Not Before CRD']
				});
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
				{
					name: 'Preferred CRD',
					value: attMap['Preferred CRD'],
					displayValue: attMap['Preferred CRD']
				});
				updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
				{
					name: 'Notes',
					value: attMap['Notes'],
					displayValue: attMap['Notes']
				});
			}
			
			updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
			{
				name: 'Call Restriction',
				value: attMap['Call Restriction'],
				displayValue: attMap['Call Restriction']
			});
		
			updateMap[selectedConfigTabName[tabNameGuid[i]]].push(
			{
				name: 'INTROAM',
				value: attMap['International Roaming'],
				displayValue: attMap['International Roaming']
			});
		}

		//await CS.SM.updateConfigurationAttribute(bulkOEComponentNameNew, updateMap).then((config) => {console.log('pushDataToParentConfigs finished: ',config)});
		if(updateMap && Object.keys(updateMap).length > 0){
			let component = await currentSolution.getComponentByName(bulkOEComponentNameNew);
			let keys = Object.keys(updateMap);		

			var complock = component.commercialLock;
			if (complock)component.lock('Commercial', false);
			for (let i = 0; i < keys.length; i++) {

				await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			}
			if (complock) component.lock('Commercial', true);
				}
		return Promise.resolve(true);
	},
	mydateToformateddate:function (){
		console.log('mydateToformateddate--->',persistentValuesNew);
		let i;
		let attName;
		
		for (i = 0; i < inputs.length; i++) {
			let type = inputs[i].getAttribute('type');
			if (type && type === 'date') { ///EDge-EDGE-137466 start
				console.log('input id--->input-'+inputs[i].getAttribute('attName'));
				d=document.getElementById('input-'+inputs[i].getAttribute('attName'));
				dt=d.getDate();
				mn=d.getMonth();
				mn++;
				yy=d.getFullYear();
				document.getElementById('date-'+inputs[i].getAttribute('attName')).value=dt+"/"+mn+"/"+yy
				document.getElementById('date-'+inputs[i].getAttribute('attName')).hidden=false;
				document.getElementById('input-'+inputs[i].getAttribute('attName')).hidden=true;
			}//EDGE-137466 end
		}
	},
	mydatehidden: function(dtId,ndtID){
		 console.log('inside date picker unhide');
		document.getElementById(dtId).hidden=false;
		document.getElementById(ndtID).hidden=true;
	},
		//EDGE-172941 INC000093743308 Fix
	getProdNumber : async function(){
		let pcidList=[];
		let solution = await CS.SM.getActiveSolution();
		let currentBasket = await CS.SM.getActiveBasket();
		if(solution.components && Object.values(solution.components).length > 0){
			Object.values(solution.components).forEach(async function (component) {
				if (component.name === bulkOEComponentNameNew) {
					if(component.schema.configurations && Object.values(component.schema.configurations).length > 0){
						Object.values(component.schema.configurations).forEach(function (config) {	
						if(!config.disabled && (config.id && config.id!='' && config.id != null && config.id!='undefined')) // INC000093907636 Fix
							pcidList.push(config.id);							
						});
					}
				}
			});
		}	
		let inputMap = {};
        inputMap['getPCId'] = pcidList.toString();
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
			retMapOE = result;
		});
		return Promise.resolve(true);
	}
 //EDGE-172941 INC000093743308 Fix End
}