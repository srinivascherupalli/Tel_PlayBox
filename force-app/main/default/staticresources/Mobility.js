/******************************************************************************************
 * Author	   : Cloud Sense Team
 Change Version History
Version No	    Author 			        Date 	 Description		
 1           Aditya Pareek			04-01-2020	 EDGE-117256 Enable search on MSISDN in solution console
 2			 Rohit Tripathi			17-03-2020	 INC000092413675 Default Value of BAR_PREMIUM is not populated in Call Restriction Field during Bulk enrichment
 3			 Sandeep Yelane			27-06-2020	 EDGE-155249  - Spring 20 Upgrade
 ********************/
console.log('OEPlugin static resource');


let deliveryDetailsHtml = '';
let deliveryDetailsAddressHtml = '';
let deliveryDetailsContactHtml = '';
let crdHtml = '';
let mfHtml = '';
let persistentValues = {};
let allOeValues = {};
let bulkOEComponentName;
let OESchemaIdMap = [];
let OEConfigurations = [];
let OEAddressSearchResult = [];
let OEAddressSearchPhrase;
let OETimeoutAddressSearch;
let OEContactSearchResult = [];
let OEContactSearchPhrase;
let OETimeoutContactSearch;
let OETimeoutNoData;
let isReadOnlyMode = true;
let isMacdOreder = false;
let OEStartX;
let OEColumnWidth;
let OEColumnToResize;
let isPreviousSelectionComplete = true;

const tooltipElement = '<div class="tooltip icon-info" id="help"  style="position:absolute; top:-3px; right:-20px;">' +
	'<span class="tooltip-arrow"></span>' +
	'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' +
	'</div>';

async function createOEUI(solutionName, componentName) {

	if (Utils.isOrderEnrichmentAllowed())
		isReadOnlyMode = false;
	//if (Utils.isFeatureAllowed())
	//isMacdOreder = true;

	console.log('createOEUI');
	bulkOEComponentName = componentName;
	isPreviousSelectionComplete = true;
	deliveryDetailsHtml = '';
	deliveryDetailsAddressHtml = '';
	deliveryDetailsContactHtml = '';
	crdHtml = '';
	mfHtml = '';
	OESchemaIdMap = [];
	OEConfigurations = [];
	OEAddressSearchPhrase = '';
	OEContactSearchPhrase = '';
	OEAddressSearchResult = [];
	OEContactSearchResult = [];
	persistentValues = {};
	allOeValues = {};
	await populateSchemaIds();
	await fetchConfigurations();

	document.getElementsByClassName('slds-text-heading_medium')[0].style.display = 'none';
	var table =
		'<div class="modal-header slds-modal__header">' +
		'<h2 class="title slds-text-heading--medium slds-hyphenate">' +
		'<div class="appLauncherModalHeader slds-grid slds-grid--align-spread  slds-m-right--small slds-m-left--small slds-grid--vertical-align-center slds-text-body--regular">'

		+
		'<div>' +
		'<h2 class="slds-text-heading--medium">Bulk Enrichment Console - ' + solutionName + '</h2>' +
		'</div>'

		+
		'<div>' +
		'<span class="icon-close" onclick="closeOe()" />' +
		'</div>'

		+
		'</div>'

		+
		'</h2>' +
		'</div>' +
		'</BR><div id="errorPannel" class="slds-theme_error"></div></BR>';


	table += '<div class="slds-grid slds-gutters" >'

		+
		'<span class="slds-spinner_container" style="display: none; position:absolute; top:350px" id="main-save-spinner-1">' +
		'<div role="status" class="slds-spinner slds-spinner slds-spinner_large slds-spinner_brand">' +
		'<span class="slds-assistive-text">Saving</span>' +
		'<div class="slds-spinner__dot-a"></div>' +
		'<div class="slds-spinner__dot-b"></div>' +
		'</div>' +
		'</span>'


		+
		'<div class="slds-col slds-size_3-of-6" onmousemove="handlemousemove(event)" onmouseup="handlemouseup(event)">'

		+
		'<div class="slds-grid slds-gutters" style="margin-bottom: 10px">' +
		'<div class="slds-col ">SELECT MOBILE SUBSCRIPTIONS</div> ' +
		'<div class="slds-col ">' +
		'<input class="slds-input " type="text" placeholder="Search..." id="configurationSearch" attName="configurationSearch" value=""' + '  onkeyup="configurationSearchKeyUp(event)" /> ' +
		'</div>' +
		'</div>'


		+
		'<div class="slds-table_header-fixed_container slds-border_top slds-border_bottom slds-border_right slds-border_left" style="height:400px;">' +
		'<div id="tableViewInnerDiv" class="slds-scrollable_y tableViewInnerDiv" style="height:100%;">' +
		'<table aria-multiselectable="true" role="grid" class="slds-table slds-table_header-fixed  slds-table_bordered  slds-table_fixed-layout slds-table_resizable-cols">' +
		'<thead>' +
		'<tr class="">';
	if (!isReadOnlyMode) {

		table += '<th   scope="col" style="width:32px">' +
			'<span id="column-group-header" class="slds-assistive-text">Choose a row</span>' +
			'<div class="slds-th__action slds-th__action_form slds-align_absolute-center slds-cell-fixed">' +
			'<div class="slds-checkbox ">' +
			'<input type="checkbox" class="pc-selection_all" name="options" id="checkboxAll" value="checkboxAll" tabindex="-1" aria-labelledby="check-select-all-label column-group-header"  onclick="updateSelectAll()" />' +
			'<label class="slds-checkbox__label" for="checkboxAll" id="check-select-all-label">' +
			'<span class="slds-checkbox_faux"></span>' +
			'  <span class="slds-form-element__label slds-assistive-text">Select All</span>' +
			'</label>' +
			'</div>' +
			'</div>' +
			'</th>';
	}

	table += ' <th aria-label="Name" aria-sort="none" class="slds-is-resizable dv-dynamic-width"  style="text-align:center; width: 350px" scope="col">' +
		' <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center dv-dynamic-width" style="width: 350px">' +
		'   <span class="slds-truncate">&nbsp;&nbsp;&nbsp;Name</span>' +
		'<div class="slds-resizable">' +
		'<span class="slds-resizable__handle" onmousedown="handlemousedown(event)">' +
		'<span class="slds-resizable__divider"></span>' +
		'</span>' +
		'</div>' +
		'</div>'

		+
		' </th>'

		+
		' <th aria-label="Model" aria-sort="none" class="slds-is-resizable" style="text-align:center" scope="col">' +
		'    <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center slds-align_absolute-center">&nbsp;&nbsp;&nbsp;Model</div>' +
		'  </th>';

	if (!isReadOnlyMode) {
		table += ' <th aria-label="Model" aria-sort="none" class="slds-is-resizable" style="text-align:center; width: 60px" scope="col">' +
			'    <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center slds-align_absolute-center">Enriched</div>' +
			'  </th>';
	}

	table += '</tr>' +
		'</thead>' +
		'<tbody id="config_table_scrollable_container">';

	table += createConfigTableRows();

	table += '</tbody>' +
		'</table>' +
		'</div>' +
		'</div>';

	table += '</div>' +
		'<div class="slds-col slds-size_3-of-6" id="main-nav-div-1">' +
		'<div class="slds-path">' +
		'  <ul class="slds-path__nav" role="listbox">' +
		'    <li class="slds-path__item slds-is-complete slds-is-active"  title="Delivery Details" role="presentation" onclick="setActive(this)">' +
		'      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="0" aria-selected="true" aria-controls="oe-tab-default-1" name="Delivery details" id="oe-tab-default-1__item">Delivery Details</a>' +
		'    </li>' +
		'    <li class="slds-path__item slds-is-complete "  title="Customer Requested Dates" role="presentation" onclick="setActive(this)">' +
		'      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-2" name="Customer requested Dates" id="oe-tab-default-2__item">Customer Requested Dates</a>' +
		'    </li>' +
		'    <li class="slds-path__item slds-is-complete" title="Features" role="presentation" onclick="setActive(this)">' +
		'      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-3" name="Mobility features" id="oe-tab-default-3__item">Features</a>' +
		'    </li>' +
		'  </ul>' +
		'  <div id="oe-tab-default-1" class="slds-tabs_default__content slds-show" role="tabpanel" aria-labelledby="oe-tab-default-1__item"><div id="delivery_oe"></div></div>' +
		'  <div id="oe-tab-default-2" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-2__item"><div id="crd_oe"></div></div>' +
		'  <div id="oe-tab-default-3" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-3__item"><div id="features_oe"></div></div>' +
		'</div>' +
		'</div>' +
		'</div>'

		+
		'<div class="modal-header slds-modal__header">' +
		'</div>';

	if (!isReadOnlyMode) {

		table += '<div style="margin-top: 10px;  margin-bottom: 10px">' +
			'<button class="slds-button slds-button_neutral slds-float_right"  onclick="saveOEForSelectedConfigs(true)">Save & Close</button>' +
			'<button class="slds-button slds-button_neutral slds-float_right" onclick="saveOEForSelectedConfigs(false)">Save</button>' +
			'</div>';
	}

	var container = document.getElementsByClassName('container');
	container[0].innerHTML = table.trim();
	container[0].style.padding = "15px";
	prepareDeliveryDetails();

	crdHtml = await prepareOETable('Customer requested Dates');
	mfHtml = await prepareOETable('Mobility features');


	document.getElementById('oe-tab-default-3__item').click();
	document.getElementById('oe-tab-default-2__item').click();
	document.getElementById('oe-tab-default-1__item').click();


	persistentValues['International Roaming'] = true;
	//added By Rohit for INC000092413675
	persistentValues['Call Restriction'] = 'BAR_PREMIUM';


	if (isReadOnlyMode) {
		setControlsAsReadonly();
	}
	return Promise.resolve(true);
}

function markConfigurationEnrichmentStatus(guid, isEnriched) {
	let notEnrichedIcon = document.getElementById('row-not-enriched-' + guid);
	let enrichedIcon = document.getElementById('row-enriched-' + guid);
	if (isEnriched) {
		enrichedIcon.style.display = 'block';
		notEnrichedIcon.style.display = 'none';
	} else {
		enrichedIcon.style.display = 'none';
		notEnrichedIcon.style.display = 'block';
	}
}

function createConfigTableRows(filterPhrase) {
	let table = '';

	for (let i = 0; i < OEConfigurations.length; i++) {
		let row = OEConfigurations[i];

		if (filterPhrase && !row.searchField.toLowerCase().includes(filterPhrase.toLowerCase()))
			continue;

		table += '<tr  class="slds-hint-parent"  onclick="onConfigurationClick(event, this)" data-value="' + row.guid + '">';
		if (!isReadOnlyMode) {

			table += '<td style="width:30px" class="slds-text-align_left" role="gridcell">' +
				'    <div class="slds-checkbox slds-align_absolute-center" >\n' +
				'       <input type="checkbox" class="pc-selection" name="options" id="checkbox-' + row.guid + '" value="' + row.guid + '" tabindex="0" aria-labelledby="' + row.guid + ' column-group-header" onclick="markSelection(event, this)"/>\n' +
				'       <label class="slds-checkbox__label" for="checkbox-' + row.guid + '" id="' + row.guid + '">\n' +
				'          <span class="slds-checkbox_faux"></span>\n' +
				'          <span class="slds-form-element__label slds-assistive-text">Select item' +
				row.name +
				'</span>\n' +
				'       </label>\n' +
				'    </div>' +
				'</td>';
		}
		table += '<td  class="slds-text-align_left slds-truncate" role="gridcell">' +
			'<div class="slds-truncate" title="' + row.name + '">' +
			row.name +
			'</div>' +
			'</td>' +
			'<td class="slds-text-align_left slds-is-resizable" role="gridcell">';

		table += '<div class="slds-truncate" ';
		table += 'title="' + row.modelName + '">';
		table += row.modelName;
		table += '</div>' +
			'</td>';


		if (!isReadOnlyMode) {
			let oeDone = isOredrEnrichmentDoneForConfiguration(row.orderEnrichmentList);

			table += '<td  class="slds-text-align_center" role="gridcell">';

			//spinner
			table += '<span class="slds-spinner_container" style="display: none" id="row-loading-' + row.guid + '">' +
				'<div role="status" class="slds-spinner slds-spinner_small slds-spinner_brand">' +
				'<div class="slds-spinner__dot-a"></div>' +
				'<div class="slds-spinner__dot-b"></div>' +
				'</div>' +
				'</span>';

			//ticked icon for enriched row

			table += '    <span class="icon-check"   id="row-enriched-' + row.guid + '"';
			if (!oeDone) {
				table += ' style="display: none" >';
			}

			table += '</span>';

			// warning info icon foe not enriched rows
			table += '<span class="tooltip icon-info"  id="row-not-enriched-' + row.guid + '"';
			if (oeDone) {
				table += ' style="display: none" >';
			}
			table += '>';
			table += '<span class="tooltip-arrow"></span>' +
				'<span class="slds-form-element__help tooltip-text">' + row.name + ' - ' + row.modelName + ' is not enriched</span>';

			table += '</span>' +
				'</td>';
		}
		table += '</tr>';
	}

	return table;
}

function handlemousedown(e) {
	//console.log('handlemousedown', e);
	OEColumnToResize = document.querySelectorAll("table thead .dv-dynamic-width");
	if (OEColumnToResize && OEColumnToResize.length > 0) {
		OEStartX = e.screenX;
		OEColumnWidth = parseInt(OEColumnToResize[0].style.width, 10);
	}
}

function handlemouseup(e) {
	//console.log('handlemouseup', e);
	OEStartX = undefined;
	OEColumnToResize = undefined;
}


function handlemousemove(e) {
	if (OEStartX && OEColumnToResize) {
		//	console.log('handlemousemove OEStartX', OEStartX);
		let width = OEColumnWidth + e.screenX - OEStartX;
		//console.log('handlemousemove dif', dif)
		if (width > 50) {
			OEColumnToResize.forEach((c) => {
				c.style.width = width + 'px';
			});
		}

	}
}
async function onConfigurationClick(ev, row) {

	if (!isPreviousSelectionComplete)
		return;

	if (ev.target.className.includes('checkbox'))
		return;

	isPreviousSelectionComplete = false;

	//if (!isReadOnlyMode) {
	//Aditya Fixes EDGE-130398
	if (basketStage == 'Contract Accepted' || (basketStage == 'Enriched') || (basketStage == 'Submitted')) {
		console.log('at341', basketStage);
		await onConfigurationPreview(row);
		console.log('at344', basketStage);
		return;
	}

	persistentValues = {};

	let configId = row.getAttribute('data-value');
	if (!configId)
		return;

	let config = OEConfigurations.filter(e => {
		return e.guid === configId
	});
	if (!config || config.length === 0)
		return;
	if (!config[0].orderEnrichmentList)
		return;
	config[0].orderEnrichmentList.forEach((oe) => {
		if (oe.attributes) {
			oe.attributes.forEach((a) => {
				if (a.type === 'Boolean') {
					persistentValues[a.name] = a.value === 'Yes' ? true : false;
				} else if (a.type === 'Date' && a.value) {
					persistentValues[a.name] = Utils.formatDate(a.value);
				} else {
					persistentValues[a.name] = a.displayValue;
				}
			});
		}
	});

	restoreValuesForCurrentTab();

	let tabs = document.getElementsByClassName('slds-path__link');
	for (let i = 0; i < tabs.length; i++) {
		if (tabs[i].getAttribute('aria-selected') === 'true' && tabs[i].id.includes('oe-tab-default-')) {
			tabs[i].click();
			break;
		}
	}

	isPreviousSelectionComplete = true;

	return Promise.resolve(true);
}

async function onConfigurationPreview(row) {
	// Spring 20 start
	let currentBasket = await CS.SM.getActiveBasket();
	// Spring 20 End
	persistentValues = {};

	let configId = row.getAttribute('data-value');
	if (!configId)
		return;

	let spinner = document.getElementById('row-loading-' + configId);
	if (spinner) {
		spinner.style.display = 'block';
	}

	let config = OEConfigurations.filter(e => {
		return e.guid === configId
	});
	if (!config || config.length === 0)
		return;
	if (!config[0].orderEnrichmentList)
		return;

	let deliveryContactId;
	let deliveryAddressId;

	config[0].orderEnrichmentList.forEach((oe) => {
		if (oe.attributes) {
			//oe.attributes.forEach((a) => {
			Object.values(oe.attributes).forEach((a) => {
				if (a.name === 'DeliveryContact') {
					deliveryContactId = a.value;
				} else if (a.name === 'DeliveryAddress') {
					deliveryAddressId = a.value;
				}

				if (a.type === 'Boolean') {
					persistentValues[a.name] = a.value === 'Yes' ? true : false;
				} else if (a.type === 'Date' && a.value) {
					persistentValues[a.name] = Utils.formatDate(a.value);
				} else {
					persistentValues[a.name] = a.displayValue;
				}
			});
		}
	});

	if (deliveryAddressId) {
		let input = {};
		// Spring 20 start
		//input["basketId"] = CS.SM.session.basketId;
		input["basketId"] = currentBasket.basketId;
		// Spring 20 End
		input["searchString"] = deliveryAddressId;
		input["option"] = 'addresses';
		// Spring 20 start
		//await CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
		await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
			// Spring 20 End		
			//	console.log('GetDeliveryDetailsLookupValues', values);
			if (values.addresses && values.addresses.length) {
				persistentValues['DeliveryAddress'] = JSON.stringify(values.addresses[0]);
			}
		});
	}

	if (deliveryContactId) {
		let input = {};
		// Spring 20 start
		//input["basketId"] = CS.SM.session.basketId;
		input["basketId"] = currentBasket.basketId;
		// Spring 20 End

		input["searchString"] = deliveryContactId;
		input["option"] = 'contact';
		// Spring 20 start
		//await CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
		await currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
			// Spring 20 End

			if (values.contact && values.contact.length) {
				persistentValues['DeliveryContact'] = JSON.stringify(values.contact[0]);
			}
		});
	}

	restoreValuesForCurrentTab();

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

	isPreviousSelectionComplete = true;
	if (spinner) {
		spinner.style.display = 'none';
	}
	return Promise.resolve(true);
}

function setControlsAsReadonly() {

	let inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
	let selects = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-select');
	let lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');
	let i;


	for (i = 0; i < inputs.length; i++) {
		inputs[i].readOnly = true;
		inputs[i].disabled = true;
	}


	for (i = 0; i < selects.length; i++) {
		selects[i].readOnly = true;
		selects[i].disabled = true;
	}

	for (i = 0; i < lookups.length; i++) {
		lookups[i].readOnly = true;
		lookups[i].disabled = true;
	}
}


function validateControl(ctl, id) {
	if (ctl) {
		let icon = document.getElementById(id);
		if (icon) {
			if (ctl.value) {
				icon.style.display = 'none';
			} else {
				icon.style.display = 'block';
			}
		}
	}
}

function closeAddressSearch() {
	let lp = document.getElementById('lookup-id-address-search');
	lp.classList.remove('slds-is-open');
}

function closeContactSearch() {
	let lp = document.getElementById('lookup-id-contact-search');
	lp.classList.remove('slds-is-open');
}

function selectDeliveryAddress(element) {
	var ase = document.getElementById('combobox-id-da-search-field');
	ase.value = element.title;
	ase.setAttribute('data-value', element.getAttribute('data-value'));
	ase.readOnly = true;
	document.getElementById('combobox-id-da-search-field-x').style.display = 'block';
	document.getElementById('combobox-id-da-search-field-info').style.display = 'none';
	OEAddressSearchPhrase = element.title;

	closeAddressSearch();
}

function selectContact(element) {
	var ase = document.getElementById('combobox-id-dc-search-field');
	ase.value = element.title;
	ase.setAttribute('data-value', element.getAttribute('data-value'));
	ase.readOnly = true;
	document.getElementById('combobox-id-dc-search-field-x').style.display = 'block';
	document.getElementById('combobox-id-dc-search-field-info').style.display = 'none';
	OEContactSearchPhrase = element.title;
	closeContactSearch();
}

function clearSelectedAddress() {
	console.log('clearSelectedAddress');
	var ase = document.getElementById('combobox-id-da-search-field');
	ase.value = '';
	ase.setAttribute('data-value', '');
	ase.readOnly = false;
	document.getElementById('combobox-id-da-search-field-x').style.display = 'none';
	document.getElementById('combobox-id-da-search-field-info').style.display = 'block';
}

function clearSelectedContact() {
	var ase = document.getElementById('combobox-id-dc-search-field');
	ase.value = '';
	ase.setAttribute('data-value', '');
	ase.readOnly = false;
	document.getElementById('combobox-id-dc-search-field-x').style.display = 'none';
	document.getElementById('combobox-id-dc-search-field-info').style.display = 'block';

}

async function configurationSearchKeyUp(event) {

	var element = document.getElementById('configurationSearch');
	if (element) {
		if (event.key === 'Enter' || !element.value || element.value.length === 0 || (element.value && element.value.length >= 3)) {
			var container = document.getElementById('config_table_scrollable_container');
			container.innerHTML = await createConfigTableRows(element.value);
		}
	}

	return Promise.resolve(true);
}

async function fetchConfigurations() {
	OEConfigurations = [];
	//Spring 20 Changes Starts Here
	let solution = await CS.SM.getActiveSolution();
	//await CS.SM.getActiveSolution().then(function(solution) {
	//solution.components.forEach(function (component) {
	Object.values(solution.components).forEach(function (component) {
		if (component.name === bulkOEComponentName) {
			//component.schema.configurations.forEach(function (config) {
			Object.values(component.schema.configurations).forEach(function (config) {
				//var disconnectionDateAttribute = config.attributes.filter(a => {
				var disconnectionDateAttribute = Object.values(config.attributes).filter(a => {
					return a.name === 'DisconnectionDate'
				});
				var ActiveConfig = config.disabled;
				if ((!disconnectionDateAttribute || disconnectionDateAttribute.length === 0 || !disconnectionDateAttribute[0].showInUi) && !ActiveConfig) {
					var row = {};
					row.guid = config.guid;

					let name = '';
					if (bulkOEComponentName === 'Mobility') {
						row.name = getNameCwpMobility(config, config.name);
						row.modelName = getModelNameCWP(config);
					} else {
						row.name = getNameEM(solution, config, config.name);
						row.modelName = getModelNameEM(config);
					}
					row.searchField = row.name + ' ' + row.modelName;
					row.orderEnrichmentList = config.orderEnrichmentList;
					OEConfigurations.push(row);
				}

			});
		}
	});
	//});  //Spring 20 commented
	//Spring 20 Changes Ends Here

	return Promise.resolve(true);
}

function isOredrEnrichmentDoneForConfiguration(orderEnrichmentList) {
	if (!orderEnrichmentList)
		return false;

	let notEnriched = orderEnrichmentList.filter((oe) => {
		//Spring 20 Changes starts Here
		//let emptyAttribute = oe.attributes.filter(a => {return a.required &&  !a.value});
		let emptyAttribute = Object.values(oe.attributes).filter(a => {
			return a.required && !a.value
		});
		//Spring 20 Changes Ends Here

		return emptyAttribute && emptyAttribute.length > 0;
	});

	if (notEnriched && notEnriched.length > 0)
		return false;

	return true;
}

function getModelNameCWP(config) {
	let modelName = '';
	if (config.relatedProductList && config.relatedProductList.length > 0) {
		config.relatedProductList.forEach((relatedConfig) => {
			if (relatedConfig.name === 'Mobile Device' && relatedConfig.type === 'Related Component') {

				var modelAtt = relatedConfig.configuration.attributes.filter(a => {
					return a.name === 'MobileHandsetModel' && a.displayValue
				});


				if (modelAtt && modelAtt.length > 0) {
					if (modelName.length > 0)
						modelName += ', ';

					modelName = modelName + modelAtt[0].displayValue;
				}
			}
		});
	}

	if (!modelName)
		return '-';

	return modelName;
}

function getModelNameEM(config) {
	let modelName = '';
	if (config.relatedProductList && config.relatedProductList.length > 0) {
		config.relatedProductList.forEach((relatedConfig) => {
			if (relatedConfig.name === 'Device' && relatedConfig.type === 'Related Component') {

				var modelAtt = relatedConfig.configuration.attributes.filter(a => {
					return a.name === 'MobileHandsetModel' && a.displayValue
				});
				var ChangeTypeDeviceAttr = relatedConfig.configuration.attributes.filter(a => {
					return a.name === 'ChangeTypeDevice'
				});
				if (modelAtt && modelAtt.length > 0 && ChangeTypeDeviceAttr[0].value !== 'PayOut' && ChangeTypeDeviceAttr[0].value !== 'PaidOut') {
					if (modelName.length > 0)
						modelName += ', ';

					modelName = modelName + modelAtt[0].displayValue;
				}
			}
		});
	}

	if (!modelName)
		return '-';

	return modelName;
}

function getNameEM(solution, config, defaultName) {
	let name = defaultName;
	//Spring 20 Changes Starts Here
	/*if (!solution.schema.configurations || solution.schema.configurations.length === 0)
		return name;

	let cmpConfig = solution.schema.configurations[0];
	var offerType= cmpConfig.attributes.filter(a => {return a.name==='OfferType'});
	*/
	if (!solution.schema.configurations || Object.values(solution.schema.configurations).length === 0)
		return name;

	let cmpConfig = Object.values(solution.schema.configurations)[0];

	var offerType = Object.values(cmpConfig.attributes).filter(a => {
		return a.name === 'OfferType'
	});
	//Spring 20 Changes ends Here	
	if (!offerType || offerType.length === 0)
		return name;

	name = offerType[0].displayValue;

	//var planType = config.attributes.filter(a => {return a.name==='SelectPlanType'});
	var planType = Object.values(config.attributes).filter(a => {
		return a.name === 'SelectPlanType'
	});
	if (planType && planType.length > 0)
		name = name + ' - ' + planType[0].displayValue;

	//var plan =  config.attributes.filter(a => {return a.name==='Select Plan'});
	var plan = Object.values(config.attributes).filter(a => {
		return a.name === 'Select Plan'
	});
	//Spring 20 Changes ends Here	
	if (plan && plan.length > 0)
		name = name + ' - ' + plan[0].displayValue;

	return name;
}

function getNameCwpMobility(config, defaultName) {
	let mobilityaName = defaultName;

	var mpAtt = config.attributes.filter((attr) => {
		return attr.name === 'MobilityPlan' && attr.displayValue
	});
	if (mpAtt && mpAtt.length > 0) {
		mobilityaName = mpAtt[0].displayValue;
	}
	return mobilityaName;
}

function setActive(elem) {

	//console.log("setActive: ", elem);
	persistValuesForCurrentTab();

	document.getElementById('errorPannel').innerHTML = '';
	let mainDiv = document.getElementById('main-nav-div-1');
	var tabs = mainDiv.getElementsByClassName('slds-path__item');
	for (var i = 0; i < tabs.length; i++) {
		tabs[i].classList.remove('slds-is-active');
	}
	var links = mainDiv.getElementsByClassName('slds-path__link');
	for (var i = 0; i < links.length; i++) {

		links[i].setAttribute('aria-selected', false);
		links[i].setAttribute('tabindex', '-1')
		var tabId = links[i].getAttribute('aria-controls');
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
	drawOETabs();

	if (isReadOnlyMode)
		setControlsAsReadonly();
}

function drawOETabs() {
	drawOETable(crdHtml, 'crd_oe');
	drawDeliveryDetails('delivery_oe');
	drawOETable(mfHtml, 'features_oe');
}

async function doAddressSearch() {
	//Spring 20 change - added
	let currentBasket = await CS.SM.getActiveBasket();
	if (isReadOnlyMode)
		return;

	closeContactSearch();
	var ase = document.getElementById('combobox-id-da-search-field');
	if (!ase || ase.readOnly)
		return;

	if (OEAddressSearchPhrase === ase.value && OEAddressSearchResult && OEAddressSearchResult.length > 0) {
		populateAddressLookup(OEAddressSearchResult);
		return;
	}

	showFetchingValuesLine(true);

	var input = {};
	// Spring 20 change start
	//input["basketId"] = CS.SM.session.basketId;
	input["basketId"] = currentBasket.basketId;
	// Spring 20 change end	
	input["searchString"] = ase.value; //ase.value;
	input["option"] = 'addresses';
	console.log('doAddressSearch: ', ase.value);
	// Spring 20 change Start
	//CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function(values) {
	currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
		// Spring 20 change end		
		OEAddressSearchPhrase = ase.value;
		OEAddressSearchResult = values.addresses;
		populateAddressLookup(values.addresses);
		ase.focus();

	});
}

async function doContactSearch() {
	//Spring 20 Change
	let currentBasket = await CS.SM.getActiveBasket();
	if (isReadOnlyMode)
		return;
	closeAddressSearch();

	var cse = document.getElementById('combobox-id-dc-search-field');
	if (!cse || cse.readOnly)
		return;

	if (OEContactSearchPhrase === cse.value && OEContactSearchResult && OEContactSearchResult.length > 0) {
		populateContactLookup(OEContactSearchResult);
		return;
	}

	showFetchingValuesLine(false);

	var input = {};
	//Spring 20 change Start
	//input["basketId"] = CS.SM.session.basketId;
	input["basketId"] = currentBasket.basketId;
	//Spring 20 change End
	input["searchString"] = cse.value;
	input["option"] = 'contact';
	console.log('doContactSearch: ', cse.value);
	//Spring 20 change Start
	//CS.SM.WebService.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function(values) {
	currentBasket.performRemoteAction('GetDeliveryDetailsLookupValues', input).then(function (values) {
		//Spring 20 change End		
		OEContactSearchPhrase = cse.value;
		OEContactSearchResult = values.contact;
		populateContactLookup(values.contact);
		cse.focus();
	});
}

function addressSearchKeyUp(event) {

	if (event.key === 'Enter') {
		doAddressSearch();
	} else {
		if (OETimeoutAddressSearch)
			clearTimeout(OETimeoutAddressSearch);
		OETimeoutAddressSearch = setTimeout(doAddressSearch, 500);
	}

}

function contactSearchKeyUp(event) {

	if (event.key === 'Enter') {
		doContactSearch();
	} else {
		if (OETimeoutContactSearch)
			clearTimeout(OETimeoutContactSearch);
		OETimeoutContactSearch = setTimeout(doContactSearch, 500);
	}
}

function createDeliveryAddressObjects(addresses) {
	deliveryDetailsAddressHtml = '';

	deliveryDetailsAddressHtml += '<div class="slds-form-element">' +
		'<label class="slds-form-element__label" for="combobox-id-da-search-field">Delivery Address</label>' +
		'<div class="slds-form-element__control" >' +
		'<div class="slds-combobox_container">' +
		'<div class="slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click" id = "lookup-id-address-search" aria-expanded="false" aria-haspopup="listbox" role="combobox">' +
		'<div class="slds-combobox__form-element slds-is-relative" role="none">' +
		'<input type="text" class="inpt-lookup slds-input slds-combobox__input" id="combobox-id-da-search-field" attName="DeliveryAddress" data-value="" aria-autocomplete="list" aria-controls="combobox-id-da-search-field" autoComplete="off" role="textbox" placeholder="Search..."  onkeyup="addressSearchKeyUp(event)"  onfocus="doAddressSearch()"/>';

	if (!isReadOnlyMode) {
		deliveryDetailsAddressHtml += '<div class="tooltip icon-info ng-star-inserted" id="combobox-id-da-search-field-info" style="position:absolute; right: 10px;">' +
			'<span class="tooltip-arrow"></span>' +
			'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' +
			'</div>' +
			'<span class="icon-close slds-float_right" onclick="clearSelectedAddress()" id="combobox-id-da-search-field-x" style="position:absolute; top:35%; right:10px; display: none"/>';
	}



	deliveryDetailsAddressHtml += '</div>' +
		'<div id="listbox-id-address-search" class="slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid" role="listbox">';

	deliveryDetailsAddressHtml += getAddressLookupResultList(OEAddressSearchResult);
	deliveryDetailsAddressHtml += '</div>' +
		'	</div>' +
		'	</div>' +
		'	</div>' +
		'	</div>';

}

function populateAddressLookup(records) {

	let lb = document.getElementById('listbox-id-address-search');
	let lp = document.getElementById('lookup-id-address-search');

	lb.innerHTML = '';
	if (records && records.length > 0) {
		lb.innerHTML = getAddressLookupResultList(records);
		lp.classList.add('slds-is-open');
	} else {
		lb.innerHTML = getNoDataLine();
		if (OETimeoutNoData)
			clearTimeout(OETimeoutNoData);
		OETimeoutNoData = setTimeout(() => {
			lp.classList.remove('slds-is-open');
		}, 2000);
	}
}

function getAddressLookupResultList(records) {
	var control = '';
	if (records && records.length > 0) {
		control = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">';
		for (let j = 0; j < records.length; j++) {
			let val = JSON.stringify(records[j]);
			control +=
				'<li role="presentation" class="slds-listbox__item">' +
				'<div id="option-da-' + j + '" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" title="' + records[j].Name + '" role="option"  onclick="selectDeliveryAddress(this)"' +
				"data-value='" + val + "'" +
				'>' +
				'<span class="slds-media__body">' +
				'<span  class="slds-truncate">' + records[j].Address_ID__c + ' | ' + records[j].Name + ' | ' + records[j].Address_Status__c + '</span>' +
				'</span>' +
				'	</div>' +
				'</li>';
		}
		control += '</ul>';
	}
	return control;
}

function createDeliveryContactObjects(contact) {
	deliveryDetailsContactHtml = '</br>';

	deliveryDetailsContactHtml += '<div class="slds-form-element">' +
		'<label class="slds-form-element__label" for="combobox-id-dc-search-field">Delivery Contact</label>' +
		'<div class="slds-form-element__control" >' +
		'<div class="slds-combobox_container">' +
		'<div class="slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click" id = "lookup-id-contact-search" aria-expanded="false" aria-haspopup="listbox" role="combobox">' +
		'<div class="slds-combobox__form-element slds-is-relative" role="none">' +
		'<input type="text" class="inpt-lookup slds-input slds-combobox__input" id="combobox-id-dc-search-field" attName="DeliveryContact" data-value="" aria-autocomplete="list" aria-controls="combobox-id-dc-search-field" autoComplete="off" role="textbox" placeholder="Search..."  onkeyup="contactSearchKeyUp(event)"  onfocus="doContactSearch()"/>';

	if (!isReadOnlyMode) {
		deliveryDetailsContactHtml += '<div class="tooltip icon-info" id="combobox-id-dc-search-field-info"  style="position:absolute; right: 10px;>' +
			'<span class="tooltip-arrow"></span>' +
			'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' +
			'</div>' +
			'<span class="icon-close " onclick="clearSelectedContact()" id="combobox-id-dc-search-field-x" style="position:absolute; top:35%; right: 10px; display: none" />';
	}

	deliveryDetailsContactHtml += '</div>' +
		'<div id="listbox-id-contact-search" class="slds-dropdown slds-dropdown_length-5 slds-dropdown_fluid"  role="listbox">';

	deliveryDetailsContactHtml += getContactLookupResultList(OEContactSearchResult);
	deliveryDetailsContactHtml += '</div>' +
		'	</div>' +
		'	</div>' +
		'	</div>' +
		'	</div>';
}

function populateContactLookup(records) {

	let lb = document.getElementById('listbox-id-contact-search');
	let lp = document.getElementById('lookup-id-contact-search');

	lb.innerHTML = '';
	if (records && records.length > 0) {
		lb.innerHTML = getContactLookupResultList(records);
		lp.classList.add('slds-is-open');
	} else {
		lb.innerHTML = getNoDataLine();
		if (OETimeoutNoData)
			clearTimeout(OETimeoutNoData);
		OETimeoutNoData = setTimeout(() => {
			lp.classList.remove('slds-is-open');
		}, 2000);
	}
}

function getContactLookupResultList(records) {
	var control = '';
	if (records && records.length > 0) {
		control = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">';
		for (let j = 0; j < records.length; j++) {
			let val = JSON.stringify(records[j]);
			control +=
				'<li role="presentation" class="slds-listbox__item">' +
				'<div id="option-dc-' + j + '" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" title="' + records[j].Name + '" role="option" onclick="selectContact(this)"' +
				"data-value='" + val + "'" +
				'>' +
				'<span class="slds-media__body">'

				+
				'<span  class="slds-truncate" >' + records[j].Name;

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

			control += '</span>' +
				'</span>' +
				'	</div>' +
				'</li>';
		}
		control += '</ul>';
	}
	return control;
}

function showFetchingValuesLine(isAddresSearch) {

	if (OETimeoutNoData)
		clearTimeout(OETimeoutNoData);

	let line = '<ul class="slds-listbox slds-listbox_vertical" role="presentation">' +
		'<li role="presentation" class="slds-listbox__item">' +
		'<div id="option-fetching-values" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" role="option" >' +
		'<span class="slds-media__body">' +
		'<span  class="slds-truncate">Fetching values... </span>' +
		'</span>' +
		'	</div>' +
		'</li>' +
		'</ul>';
	if (isAddresSearch) {
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
}

function getNoDataLine() {

	return '<ul class="slds-listbox slds-listbox_vertical" role="presentation">' +
		'<li role="presentation" class="slds-listbox__item">' +
		'<div id="option-fetching-values" class="slds-media slds-listbox__option slds-listbox__option_plain slds-media_small" role="option" >' +
		'<span class="slds-media__body">' +
		'<span  class="slds-truncate">No data</span>' +
		'</span>' +
		'	</div>' +
		'</li>' +
		'</ul>';

}

function prepareDeliveryDetails() {

	createDeliveryAddressObjects();
	createDeliveryContactObjects();
	drawDeliveryDetails('delivery_oe');
}

function drawDeliveryDetails(oeId) {
	persistValuesForCurrentTab();
	deliveryDetailsHtml = deliveryDetailsAddressHtml + deliveryDetailsContactHtml;
	var el = document.getElementById(oeId);
	if (el)
		el.innerHTML = deliveryDetailsHtml.trim();
	restoreValuesForCurrentTab();
}


async function prepareOETable(oeName) {
	let grid = '';


	await getOEAttributes(oeName).then(function (oe) {
		//Spring 20 changes Start here
		//oe.schema.attributes.forEach(function(attr) {
		Object.values(oe.schema.attributes).forEach(function (attr) {
			//Spring 20 changes Start end
			if (attr.showInUi) {
				let helpIconId;
				if (attr.type === 'String') {
					grid += '<div>';
					grid += '<div class="slds-form-element">';
					grid += '<label class="slds-form-element__label">' +
						'<span>' + attr.label + '</span>';
					if (attr.required && !isReadOnlyMode) {
						grid += tooltipElement;
					}
					grid += '</label>' +
						'<div class="slds-form-element__control">' +
						'<input class="inpt" type="text" attName="' + attr.name + '" value="' + attr.value + '"' +
						'class="slds-input"/>' +
						'</div>' +
						'</div>';
					grid += '</div>';
				} else if (attr.type === 'Boolean') {
					grid += '<div>';
					grid += '<div class="slds-form-element">';
					grid += '<label class="slds-form-element__label">' +
						'<span>' + attr.label + '</span>';
					if (attr.required && !isReadOnlyMode) {
						grid += tooltipElement;
					}
					grid += '</label>' +
						'<div class="slds-form-element__control">' +
						'<input attName="' + attr.name + '" class="inpt" type="checkbox" id="checkbox-' + attr.name + '" value="' + attr.value + '"' +
						'class="slds-input"/>' +
						'</div>' +
						'</div>';
					grid += '</div>';
				} else if (attr.type === 'Date') {
					grid += '<div>';
					grid += '<div class="slds-form-element">';
					grid += '<label class="slds-form-element__label">' +
						'<span>' + attr.label + '</span>';

					if (attr.required && !isReadOnlyMode) {
						//grid += tooltipElement;
						helpIconId = 'help-' + attr.name;
						grid += '<div class="tooltip icon-info" id="' + helpIconId + '"  style="position:absolute; top:-3px; right:-20px;">' +
							'<span class="tooltip-arrow"></span>' +
							'<span class="slds-form-element__help tooltip-text">This value can not be empty</span>' +
							'</div>';
					}

					grid += '</label>' +
						'<div class="slds-form-element__control">' +
						'<input  attName="' + attr.name + '" class="inpt" type="date" value="' + attr.value + '" id="input-' + attr.name + '"';

					if (attr.required) {
						grid += ' onchange="validateControl(this , \'' + helpIconId + '\')"  ';
					}

					grid += 'class="slds-input" />' +
						'</div>' +
						'</div>';
					grid += '</div>';
				} else if (attr.type === 'Picklist') {
					var value = attr.value;
					grid += '<div>';
					grid += '<div class="slds-form-element">';
					grid += '<label class="slds-form-element__label">' +
						'<span>' + attr.label + '</span>';

					if (attr.required && !isReadOnlyMode) {
						grid += tooltipElement;
					}
					grid += '</label>' +
						'<div class="slds-form-element__control">' +
						'<select attName="' + attr.name + '" class="inpt-select" class="slds-select" data-id="' + attr.name + '">';
					for (var j = 0; j < attr.options.length; j++) {
						if (attr.options[j] == value) {
							grid += '<option value="' + attr.options[j] + '" selected>' + attr.options[j] + '</option>';
						} else {
							grid += '<option value="' + attr.options[j] + '">' + attr.options[j] + '</option>';
						}
					}
					grid += '</select>' +
						'</div>' +
						'</div>';
					grid += '</div>';
				}

			}
		});
	});
	return grid.trim();
}

function drawOETable(tableHtml, oeId) {

	document.getElementById(oeId).innerHTML = tableHtml;
	restoreValuesForCurrentTab();
}

async function getOEAttributes(oeName) {
	// Spring 20 Changes Starts
	let solution = await CS.SM.getActiveSolution();
	//return CS.SM.getActiveSolution().then(function(solution) {
	var retVal;
	//solution.components.forEach(function(comp) {
	Object.values(solution.components).forEach(function (comp) {
		if (comp.name === bulkOEComponentName) {
			//comp.orderEnrichments.forEach(function(oe) {
			Object.values(comp.orderEnrichments).forEach(function (oe) {
				if (oe.name === oeName) {
					retVal = oe;
				}
			})
		}
	});
	//console.log('getOEAttributes: ', oeName, retVal );
	//return retVal;
	return Promise.resolve(retVal);
	//});  
	// Spring 20 Changes Ends 
}

function markSelection(ev, el) {

	ev.stopPropagation();

	var row = Utils.getClosestParent(el, 'tr');
	if (el.checked) {
		row.classList.add('slds-is-selected');
		row.setAttribute('aria-selected', true);
	} else {
		row.classList.remove('slds-is-selected');
		row.setAttribute('aria-selected', false);
	}
}

function updateSelectAll() {
	var selections = document.getElementsByClassName('pc-selection');
	var selectAll = document.getElementById('checkboxAll');
	for (var i = 0; i < selections.length; i++) {
		selections[i].checked = selectAll.checked
		var row = Utils.getClosestParent(selections[i], 'tr');
		if (selections[i].checked) {
			row.classList.add('slds-is-selected');
			row.setAttribute('aria-selected', true);
		} else {
			row.classList.remove('slds-is-selected');
			row.setAttribute('aria-selected', false);
		}
	}
}

function getSelectedConfigurations() {
	var selections = document.getElementsByClassName('pc-selection');
	var configIds = [];
	for (var i = 0; i < selections.length; i++) {
		if (selections[i].checked) {
			configIds.push(selections[i].getAttribute('value'));
		}
	}
	console.log('getSelectedConfigurations:', configIds);
	return configIds;
}

async function populateSchemaIds() {
	OESchemaIdMap = {};
	// Spring 20 Changes Starts here
	let solution = await CS.SM.getActiveSolution();
	//await CS.SM.getActiveSolution().then(function (solution) {
	//solution.components.forEach(function (comp)
	Object.values(solution.components).forEach(function (comp) {
		if (comp.name === bulkOEComponentName) {
			//comp.orderEnrichments.forEach(function (oe) {
			if (comp.name === bulkOEComponentName) {
				Object.values(comp.orderEnrichments).forEach(function (oe) {
					OESchemaIdMap[oe.name] = oe.id;
				});
			}
		}
	});
	// Spring 20 Changes ends here
	return Promise.resolve(true);
}

// async function populateSchemaIds() {
// 	OESchemaIdMap = [];
// 	// Spring 20 Changes Starts here
// 	let solution = await CS.SM.getActiveSolution();
// 	//await CS.SM.getActiveSolution().then(function (solution) {
// 	//solution.components.forEach(function (comp)
// 	Object.values(solution.components).forEach(function (comp) {
// 		if (comp.name === bulkOEComponentName) {
// 			//comp.orderEnrichments.forEach(function (oe) {
// 			Object.values(comp.orderEnrichments).forEach(function (oe) {
// 				let el = {};
// 				el.componentName = comp.name;
// 				el.configGuid = config.guid;
// 				el.oeSchema = oeSchema;
// 				OESchemaIdMap.push(el);
// 			});
// 		}
// 	});

// 	//});
// 	// Spring 20 Changes ends here
// 	return Promise.resolve(true);
// }



function getAttributeMap() {

	if (isReadOnlyMode)
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
	allItems = Array.prototype.concat.apply(allItems, inputs);
	allItems = Array.prototype.concat.apply(allItems, inputselect);
	var attributeMap = [];
	var attrs = {};
	for (var i = 0; i < allItems.length; i++) {
		var type = allItems[i].getAttribute('type');
		if (type && type === 'checkbox') {
			attrs[allItems[i].getAttribute('attName')] = allItems[i].checked ? 'Yes' : 'No';
		} else {
			attrs[allItems[i].getAttribute('attName')] = allItems[i].value;
		}
	}


	for (var i = 0; i < lookups.length; i++) {
		var attName = lookups[i].getAttribute('attName');
		if (attName.includes('DeliveryContact')) {
			//	console.log('DeliveryContact: ',lookups[i].getAttribute('data-value'))
			var parsedData = lookups[i].getAttribute('data-value') ? JSON.parse(lookups[i].getAttribute('data-value')) : {};
			attrs['DeliveryContact'] = parsedData.Id ? parsedData.Id : '';
			attrs['FirstName'] = parsedData.FirstName ? parsedData.FirstName : '';
			attrs['LastName'] = parsedData.LastName ? parsedData.LastName : '';
			attrs['Phone'] = parsedData.Phone ? parsedData.Phone : '';
			attrs['Mobile'] = parsedData.MobilePhone ? parsedData.MobilePhone : '';
			attrs['Email'] = parsedData.Email ? parsedData.Email : '';
			attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;
		} else if (attName.includes('DeliveryAddress')) {
			//	console.log('DeliveryAddress: ',lookups[i].getAttribute('data-value'))
			var parsedData = lookups[i].getAttribute('data-value') ? JSON.parse(lookups[i].getAttribute('data-value')) : {};
			attrs['DeliveryAddress'] = parsedData.Id ? parsedData.Id : '';
			attrs['ADBOIRId'] = parsedData.Address_ID__c ? parsedData.Address_ID__c : '';
			attrs['Postcode'] = parsedData.cscrm__Zip_Postal_Code__c ? parsedData.cscrm__Zip_Postal_Code__c : '';
			attrs['Street'] = parsedData.Street_calc__c ? parsedData.Street_calc__c : '';
			attrs['IsDeliveryDetailsEnriched'] = attrs['DeliveryContact'] && attrs['DeliveryAddress'] ? true : false;
		} else {
			attrs[attName] = JSON.parse(lookups[i].getAttribute('data-value'));
		}
	}
	attributeMap.push(attrs);
	return attributeMap;
}

function persistValuesForCurrentTab() {

	if (isReadOnlyMode)
		return;
	let inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
	let selects = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-select');
	let lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');
	let i;
	let attName;
	for (i = 0; i < inputs.length; i++) {
		var type = inputs[i].getAttribute('type');
		if (type && type === 'checkbox') {
			persistentValues[inputs[i].getAttribute('attName')] = inputs[i].checked;
		} else {
			persistentValues[inputs[i].getAttribute('attName')] = inputs[i].value;
		}
	}

	for (i = 0; i < selects.length; i++) {
		attName = selects[i].getAttribute('attName');

	}

	for (i = 0; i < lookups.length; i++) {
		attName = lookups[i].getAttribute('attName');
		persistentValues[attName] = lookups[i].getAttribute('data-value');
	}

	let links = document.getElementsByClassName('slds-path__link');
	for (i = 0; i < links.length; i++) {
		if (links[i].getAttribute('aria-selected') === 'true') {
			allOeValues[links[i].getAttribute('name')] = getAttributeMap();
			break;
		}
	}
}

function restoreValuesForCurrentTab() {

	console.log('restoreValuesForCurrentTab', persistentValues);

	let inputs = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt');
	let selects = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-select');
	let lookups = document.getElementsByClassName('slds-show')[0].children[0].getElementsByClassName('inpt-lookup');
	let i;
	let attName;
	let helpIconId;
	let info;

	for (i = 0; i < inputs.length; i++) {
		let type = inputs[i].getAttribute('type');

		if (type && type === 'checkbox') {
			if (persistentValues[inputs[i].getAttribute('attName')]) {
				inputs[i].checked = persistentValues[inputs[i].getAttribute('attName')];
			}
		} else {
			//if (persistentValues[inputs[i].getAttribute('attName')]) {
			inputs[i].value = persistentValues[inputs[i].getAttribute('attName')];
			//}
		}

		if (persistentValues[inputs[i].getAttribute('attName')]) {
			helpIconId = 'help-' + inputs[i].getAttribute('attName');
			info = document.getElementById(helpIconId);
			if (info) {
				info.style.display = 'none';
			}
		}
	}


	for (i = 0; i < selects.length; i++) {
		attName = selects[i].getAttribute('attName');
		//if (persistentValues[attName]) {
		selects[i].value = persistentValues[attName];
		//}

		if (persistentValues[attName]) {
			helpIconId = 'help-' + attName;
			info = document.getElementById(helpIconId);
			if (info) {
				info.style.display = 'none';
			}
		}
	}

	for (i = 0; i < lookups.length; i++) {
		attName = lookups[i].getAttribute('attName');
		if (persistentValues[attName]) {
			lookups[i].setAttribute('data-value', persistentValues[attName]);

			if (!isReadOnlyMode) {
				lookups[i].value = JSON.parse(persistentValues[attName]).Name;

				let xButton = document.getElementById(lookups[i].id + '-x');
				lookups[i].readOnly = true;
				xButton.style.display = 'block';
				console.log('insideif: ', lookups[i].value);
			} else {
				//Aditya Fixes EDGE-130398
				lookups[i].value = JSON.parse(persistentValues[attName]).Name;
				// lookups[i].value = persistentValues[attName];
				console.log('insideelse: ', lookups[i].value);
			}

			info = document.getElementById(lookups[i].id + '-info');
			if (info) {
				info.style.display = 'none';
			}
		} else {
			lookups[i].setAttribute('data-value', '');
			lookups[i].value = '';

			if (!isReadOnlyMode) {
				let xButton = document.getElementById(lookups[i].id + '-x');
				lookups[i].readOnly = false;
				xButton.style.display = 'none';
			}

			info = document.getElementById(lookups[i].id + '-info');
			if (info) {
				info.style.display = 'block';
			}
		}
	}
	// if(isMacdOreder)
	// ReadOnlyMobileFeature();
}

function ReadOnlyMobileFeature() {

	var links = document.getElementsByClassName('slds-path__link');
	for (var x = 0; x < links.length; x++) {
		selected = links[x].getAttribute('name');
		if (selected !== null && selected.toLowerCase() === 'Mobility features'.toLowerCase()) {
			var selectedId = links[x].getAttribute('aria-controls');
			var inputsCheck = document.getElementById(selectedId).children[0].getElementsByClassName('inpt');
			let selectsList = document.getElementById(selectedId).children[0].getElementsByClassName('inpt-select');
			let lookupsValue = document.getElementById(selectedId).children[0].getElementsByClassName('inpt-lookup');
			let j;
			let k;
			let L;
			for (j = 0; j < inputsCheck.length; j++) {
				inputsCheck[j].setAttribute('disabled', true);
			}
			for (k = 0; k < selectsList.length; k++) {
				selectsList[k].setAttribute('disabled', true);
			}
			for (L = 0; L < lookupsValue.length; L++) {
				lookupsValue[L].setAttribute('disabled', true);
			}
		}
	}
}

function closeOe() {
	//sessionStorage.setItem("close", "close");
	var el = document.getElementsByClassName('cdk-overlay-backdrop cdk-overlay-dark-backdrop cdk-overlay-backdrop-showing');
	if (el) {
		for (var i = 0; i < el.length; i++) {
			el[i].click();
		}
	}
}

async function saveOEForSelectedConfigs(closAfterSave) {

	let spinner = document.getElementById('main-save-spinner-1');
	spinner.style.display = 'block';

	var attributeMap;
	var selectedConfigs;
	var isValid = false;

	persistValuesForCurrentTab();

	selectedConfigs = getSelectedConfigurations();
	isValid = await validateData();
	// Spring 20 Changes Starts here
	var oeMap = [];
	let solution = await CS.SM.getActiveSolution();
	if (isValid) {
		for (let j = 0; j < Object.values(solution.components).length; j++) {
			let comp = Object.values(solution.components)[j];
			if (comp.name === bulkOEComponentName) {
				for (let k = 0; k < Object.values(comp.schema.configurations).length; k++) {
					let config = Object.values(comp.schema.configurations)[k];
					// New Code need to check which one to keep old one or new one
					// Object.values(comp.orderEnrichments).forEach((oeSchema) => {
					// 	var el = {};
					// 	el.configGUID = config.guid;
					// 	el.oeSChema = oeSchema;
					// 	oeMap.push(el);
					// })
					// Spring 20 Changes ends here
					if (selectedConfigs.contains(config.guid)) {
						var oldList = [];
						Object.keys(allOeValues).forEach(key => {
							attributeMap = allOeValues[key];
							if (config.orderEnrichmentList) {
								config.orderEnrichmentList.forEach((oe) => {
									//	console.log('Mobility oe: ', oe);
									var shouldDelete = true;
									if (attributeMap && attributeMap.length > 0) {
										for (var key in attributeMap[0]) {
											//	console.log('key: ', key);
											// Spring 20 Changes starts here
											//var a = oe.attributes.filter(at => {
											var a = Object.values(oe.attributes).filter(at => {
												// Spring 20 Changes ends here
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
						// Spring 20 Changes starts here
						//if (oldList.length > 0) {
						console.log('Mobility deleteOrderEnrichments: ', oldList);

						//await CS.SM.deleteOrderEnrichments(bulkOEComponentName, config.guid, oldList, true);
						for(var h = 0 ; h < oldList.length; h++){
							//await solution.deleteOrderEnrichmentConfiguration(config.guid,oldList[h],false).then(() => Promise.resolve(true));
							console.log('Calling deleteOeConfig');
							comp.deleteOrderEnrichmentConfiguration(config.guid,oldList[h],false);
						}
						//}
						// Spring 20 Changes ends here
					}
				}
			}
			console.log('In OuterFor');
		}
	}


	if (selectedConfigs && selectedConfigs.length > 0 && isValid) {

		// Arinjay
/*
		let desiredConfig;
		let desiredComponent ;
		outer:
		for (let j = 0; j < Object.values(solution.components).length; j++) {
			let comp = Object.values(solution.components)[j];
			if (comp.name === bulkOEComponentName) {
				for (let k = 0; k < Object.values(comp.schema.configurations).length; k++) {
					let config = Object.values(comp.schema.configurations)[k];
					if (selectedConfigs.contains(config.guid)) {
						desiredConfig = config;
						desiredComponent = comp;
						break outer;
					}
				}
			}
		}
*/
		// Arinjay
		
		for (let i = 0; i < selectedConfigs.length; i++) {
			let oeDataKeys = Object.keys(allOeValues);
			for (let l = 0; l < oeDataKeys.length; l++) {
				let key1 = oeDataKeys[l];
				let desiredComponent ;
				if (solution.components && Object.values(solution.components).length > 0) {
					//Object.values(solution.components).forEach((comp) => {
					for(var comp of Object.values(solution.components)){
						if(comp.orderEnrichments){
							//Object.values(comp.orderEnrichments).forEach((oeSchema) => {
							for(var oeSchema of Object.values(comp.orderEnrichments)){
								if (oeSchema.name.includes(key1)) {
									desiredComponent = oeSchema;
								}
							}
						}
					}
				}
				attributeMap = allOeValues[key1][0];
				let aData = [];
				
				for(var attrName in attributeMap){
					aData.push({name:attrName,value: { value:attributeMap[attrName], displayValue:attributeMap[attrName]}});
				}
				// Spring 20 Changes starts here
				//await CS.SM.addOrderEnrichments(bulkOEComponentName, selectedConfigs[i], OESchemaIdMap[key1], attributeMap);
				// Spring 20 Changes ends here
				let component = solution.findComponentsByConfiguration(selectedConfigs[i]);
				let oeConfiguration = desiredComponent.createConfiguration(aData);
				await component.addOrderEnrichmentConfiguration(selectedConfigs[i], oeConfiguration, false );
				//console.log(selectedConfigs[i]);
				//console.log(OESchemaIdMap[key1]);
				markConfigurationEnrichmentStatus(selectedConfigs[i], true);
			}
		}
		// New Code need to check which one to keep old one or new one
		// let currentSolution = await CS.SM.getActiveSolution();
		// if(oeMap.length > 0){
		// 	let map = [];
		// 	map.push({});
		// 	for(let  k = 0 ; k < oeMap.length ; k++){
		// 		console.log(' oeMap ----' + oeMap[k]);
		// 		let orderEnrichmentConfiguration = oeMap[k].oeSchema.createConfiguration(map);
		// 		let component = currentSolution.findComponentsByConfiguration(oeMap[k].configGuid);
		// 		await component.addOrderEnrichmentConfiguration(oeMap[k].configGuid, orderEnrichmentConfiguration, false);

		// 	}
		// }
		await pushDataToParentConfigs(selectedConfigs);

		CS.SM.displayMessage('Selected configurations updated successfully!', 'success');
		if (closAfterSave) {
			closeOe();
		} else {
			await fetchConfigurations();
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

Array.prototype.contains = function (obj) {
	var i = this.length;
	while (i--) {
		if (this[i] == obj) {
			return true;
		}
	}
	return false;
}

async function validateData() {
	// Spring 20 Changes Starts here
	let currentBasket = await CS.SM.getActiveBasket();
	// Spring 20 Changes ends here
	//console.log('validateData attributeMap ', attributeMap)
	var errorPanel = document.getElementById('errorPannel');
	var selected = '';
	var errorMessages = [];
	var links = document.getElementsByClassName('slds-path__link');
	for (var i = 0; i < links.length; i++) {
		selected = links[i].getAttribute('name');
		var attributeMap = allOeValues[selected];

		if (attributeMap && attributeMap.length > 0) {
			if (selected.toLowerCase() === 'Delivery details'.toLowerCase()) {
				console.log('Delivery Contact', attributeMap[0]['DeliveryContact']);
				console.log('Delivery Contact', attributeMap[0]);

				if (!attributeMap[0]['DeliveryContact']) {
					errorMessages.push('Delivery contact is not selected');
				}
				if (!attributeMap[0]['Email']) {
					errorMessages.push('Selected delivery contact does not have email id or phone number; Please update the contact details');
				}
				if (!attributeMap[0]['Phone']) {
					errorMessages.push('Selected delivery contact does not have email id or phone number; Please update the contact details');
				}
				if ((!attributeMap[0]['Email']) && (!attributeMap[0]['Phone'])) {
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
			} else if (selected.toLowerCase() === 'Customer requested Dates'.toLowerCase()) {

				if (!attributeMap[0]['Not Before CRD']) {
					errorMessages.push('Not Before CRD is not populated');
				} else {
					var crd = new Date(attributeMap[0]['Not Before CRD']);
					var today = new Date();
					today.setHours(0, 0, 0, 0);
					crd.setHours(0, 0, 0, 0);
					if (crd <= today) {
						errorMessages.push('Not Before CRD can not be before today');
					}
					console.log('bulkOEComponentName result:', bulkOEComponentName);
					if (bulkOEComponentName == 'Mobility' || bulkOEComponentName == 'Mobile Subscription') {
						//EDGE-92626
						// Spring 20 Changes Starts here
						//var basketId = CS.SM.session.basketId;
						var InputMap = {};
						InputMap['NotBefCRD'] = crd;
						//InputMap['basketId'] = basketId;
						InputMap['basketId'] = currentBasket.basketId;
						//console.log('InputMap:', InputMap);
						if (NotBefCRD = !null) {
							//await CS.SM.WebService.performRemoteAction('EnrichmentValidationRemoter', InputMap).then(result => {
							await currentBasket.performRemoteAction('EnrichmentValidationRemoter', InputMap).then(result => {
								// Spring 20 Changes ends here
								//	console.log('EnrichmentValidationRemoter result:', result);
								if (result && result != undefined) {
									if (result.validationCRD && result.validationCRD === true) {
										//errorPanel.innerHTML += 'Not Before CRD should be at least 15 days prior to the CA Expiry Date, please select a correct Not Before CRD or generate a new CA for customer sign off</BR>'
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
		// Spring 20 Changes Starts here
		//return false;
		return Promise.resolve(false);
	}
	//return true;
	return Promise.resolve(true);
	// Spring 20 Changes ends here
}

async function pushDataToParentConfigs(selectedConfigs) {
	// Spring 20 Changes starts here
	let solution = await CS.SM.getActiveSolution();
	// Spring 20 Changes ends here
	console.log('pushDataToParentConfigs');
	updateMap = {};
	var attMap = [];
	var attributeMap;
	Object.keys(allOeValues).forEach(key => {
		attributeMap = allOeValues[key];
		Object.keys(attributeMap[0]).forEach(key1 => {
			attMap[key1] = attributeMap[0][key1];
		});
	});

	for (var i = 0; i < selectedConfigs.length; i++) {

		updateMap[selectedConfigs[i]] = [];
		// Spring 20 Changes starts here
		updateMap[selectedConfigs[i]].push({
			name: 'SiteDeliveryContact',
			value: attMap['DeliveryContact']
			/*value: {
				value: attMap['DeliveryContact']
			}*/
		});
		updateMap[selectedConfigs[i]].push({
			name: 'SiteDeliveryAddress',
			value: attMap['DeliveryAddress']
			/*value: {
				value: attMap['DeliveryAddress']
			}*/
		});

		updateMap[selectedConfigs[i]].push({
			name: 'Not Before CRD',
			value: attMap['Not Before CRD'],
			displayValue: attMap['Not Before CRD']
			/*value: {
				value: attMap['Not Before CRD'],
				displayValue: attMap['Not Before CRD']
			}*/
		});
		updateMap[selectedConfigs[i]].push({
			name: 'Preferred CRD',
			value: attMap['Preferred CRD'],
			displayValue: attMap['Preferred CRD']
			/*value: {
				value: attMap['Preferred CRD'],
				displayValue: attMap['Preferred CRD']
			}*/
		});
		updateMap[selectedConfigs[i]].push({
			name: 'Notes',
			value: attMap['Notes'],
			displayValue: attMap['Notes']
			/*value: {
				value: attMap['Notes'],
				displayValue: attMap['Notes']
			}*/
		});

		updateMap[selectedConfigs[i]].push({
			name: 'Call Restriction',
			value: attMap['Call Restriction'],
			displayValue: attMap['Call Restriction']
			/*value: {
				value: attMap['Call Restriction'],
				displayValue: attMap['Call Restriction']
			}*/
		});

		updateMap[selectedConfigs[i]].push({
			name: 'INTROAM',
			value: attMap['International Roaming'],
			displayValue: attMap['International Roaming']
			/*value: {
				value: attMap['International Roaming'],
				displayValue: attMap['International Roaming']
			}*/
		});
		// Spring 20 Changes ends here

	}
	// Spring 20 Changes starts here
	if (updateMap && Object.keys(updateMap).length > 0) {
		keys = Object.keys(updateMap);
		let component = solution.getComponentByName(bulkOEComponentName);
		var complock = component.commercialLock;

		if (complock) 
			component.lock('Commercial', false);
		for (let i = 0; i < keys.length; i++) {
			//component.lock('Commercial', false);
			component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
			//component.lock('Commercial', true);
		}
		if (complock) 
			component.lock('Commercial', false);
	}
	//await CS.SM.updateConfigurationAttribute(bulkOEComponentName, updateMap).then((config) => {console.log('pushDataToParentConfigs finished: ',config)});
	// Spring 20 Changes ends here	
	return Promise.resolve(true);

}