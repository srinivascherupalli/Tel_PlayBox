async function createBulkOE(solutionName, componentName) {

	if (Utils.isOrderEnrichmentAllowed())
		isReadOnlyMode = false;

	console.log('createOEUI');
	bulkOEComponentName = componentName;

	deliveryDetailsHtml = '';
	deliveryDetailsAddressHtml = '';
	deliveryDetailsContactHtml = '';
	crdHtml = '';
	mfHtml = '';
	OESchemaIdMap={};
	OEConfigurations=[];
	OEAddressSearchPhrase = '';
	OEContactSearchPhrase = '';
	OEAddressSearchResult = [];
	OEContactSearchResult=[];
	persistentValues = {};
	allOeValues = {};
	await populateSchemaIds();
	await fetchConfigurations();

	document.getElementsByClassName('slds-text-heading_medium')[0].style.display = 'none';
	var table =
        '<div class="modal-header slds-modal__header">'
        +'<h2 class="title slds-text-heading--medium slds-hyphenate">'
        + '<div class="appLauncherModalHeader slds-grid slds-grid--align-spread  slds-m-right--small slds-m-left--small slds-grid--vertical-align-center slds-text-body--regular">'

        +'<div>'
        +'<h2 class="slds-text-heading--medium">Bulk Enrichment Console - '+ solutionName +'</h2>'
        +'</div>'

        +'<div>'
        + '<span class="icon-close" onclick="closeOe()" />'
        +'</div>'

        +'</div>'

        + '</h2>'
        +'</div>'
        + '</BR><div id="errorPannel" class="slds-theme_error"></div></BR>';


	table += '<div class="slds-grid slds-gutters" >'
		+ '<span class="slds-spinner_container" style="display: none; position:absolute; top:350px" id="main-save-spinner-1">'
		+'<div role="status" class="slds-spinner slds-spinner slds-spinner_large slds-spinner_brand">'
		+'<span class="slds-assistive-text">Saving</span>'
		+'<div class="slds-spinner__dot-a"></div>'
		+'<div class="slds-spinner__dot-b"></div>'
		+'</div>'
		+'</span>'
		
		+ '<div class="slds-col slds-size_3-of-6 slds-scrollable" style="max-height:300px" onmousemove="handlemousemove(event)" onmouseup="handlemouseup(event)">'

		+ '<div class="slds-grid slds-gutters" style="margin-bottom: 10px">'
		+ '<div class="slds-col ">SELECT IOT SUBSCRIPTIONS</div> '
		+ '<div class="slds-col ">'
		+ '<input class="slds-input " type="text" placeholder="Search..." id="configurationSearch" attName="configurationSearch" value=""' + '  onkeyup="configurationSearchKeyUp(event)" /> '
		+'</div>'
		+'</div>'


		+ '<div class="slds-table_header-fixed_container slds-border_top slds-border_bottom slds-border_right slds-border_left slds_scrollable" style="max-height:300px;">'
		+ '<div id="tableViewInnerDiv" class="slds-scrollable_y tableViewInnerDiv" style="max-height:300px;">'
		+ '<table aria-multiselectable="true" role="grid" class="slds-table slds-table_header-fixed  slds-table_bordered  slds-table_fixed-layout slds-table_resizable-cols">'
		+ '<thead>'
		+ '<tr class="">';
	if (!isReadOnlyMode) {
		table += '<th   scope="col" style="width:32px">'
			+ '<span id="column-group-header" class="slds-assistive-text">Choose a row</span>'
			+ '<div class="slds-th__action slds-th__action_form slds-align_absolute-center slds-cell-fixed">'
			+ '<div class="slds-checkbox ">'
			+ '<input type="checkbox" class="pc-selection_all" name="options" id="checkboxAll" value="checkboxAll" tabindex="-1" aria-labelledby="check-select-all-label column-group-header"  onclick="updateSelectAll()" />'
			+ '<label class="slds-checkbox__label" for="checkboxAll" id="check-select-all-label">'
			+ '<span class="slds-checkbox_faux"></span>'
			+ '  <span class="slds-form-element__label slds-assistive-text">Select All</span>'
			+ '</label>'
			+ '</div>'
			+ '</div>'
			+ '</th>';
	}

	table += ' <th aria-label="Name" aria-sort="none" class="slds-is-resizable dv-dynamic-width"  style="text-align:center; width: 350px" scope="col">'
		+ ' <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center dv-dynamic-width" style="width: 350px">'
		+ '   <span class="slds-truncate">&nbsp;&nbsp;&nbsp;Name</span>'
		+	'<div class="slds-resizable">'
		+		'<span class="slds-resizable__handle" onmousedown="handlemousedown(event)">'
		+			'<span class="slds-resizable__divider"></span>'
		+		'</span>'
		+	'</div>'
		+'</div>'

		+ ' </th>'

		+ ' <th aria-label="Model" aria-sort="none" class="slds-is-resizable" style="text-align:center" scope="col">'
		+ '    <div class="slds-grid slds-cell-fixed slds-grid_vertical-align-center slds-align_absolute-center">&nbsp;&nbsp;&nbsp;Model</div>'
		+ '  </th>'
		+ '</tr>'
		+ '</thead>'
		+ '<tbody id="config_table_scrollable_container">';

		table += createConfigTableRows();

	table += '</tbody>'
	    +  '</table>'
		+  '</div>'
		+  '</div>';

		table +=  '</div>'
			+ '<div class="slds-col slds-size_3-of-6 slds-scrollable" style="max-height:300px" id="main-nav-div-1">'
			+ '<div class="slds-path">'
			+ '  <ul class="slds-path__nav" role="listbox">'
			+ '    <li class="slds-path__item slds-is-complete slds-is-active" title="Delivery Details" role="presentation" onclick="setActive(this)">'
			+ '      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="0" aria-selected="true" aria-controls="oe-tab-default-1" name="Delivery details" id="oe-tab-default-1__item">Delivery Details</a>'
			+ '    </li>'
			+ '    <li class="slds-path__item slds-is-complete " title="Customer Requested Dates" role="presentation" onclick="setActive(this)">'
			+ '      <a class="slds-path__link" href="javascript:void(0);" role="option" tabindex="-1" aria-selected="false" aria-controls="oe-tab-default-2" name="Customer requested Dates" id="oe-tab-default-2__item">Customer Requested Dates</a>'
			+ '    </li>'
			+ '  </ul>'
			+ '  <div id="oe-tab-default-1" class="slds-tabs_default__content slds-show" role="tabpanel" aria-labelledby="oe-tab-default-1__item"><div id="delivery_oe"></div></div>'
			+ '  <div id="oe-tab-default-2" class="slds-tabs_default__content slds-hide" role="tabpanel" aria-labelledby="oe-tab-default-2__item"><div id="crd_oe"></div></div>'
			+ '</div>'
			+ '</div>'
			+ '</div>'
			+ '<div class="modal-header slds-modal__header">'
			+ '</div>';

		if (!isReadOnlyMode) {

		table +='<div style="margin-top: 10px;  margin-bottom: 10px">'
		+ '<button class="slds-button slds-button_neutral slds-float_right"  onclick="saveOEForSelectedConfigs(true)">Save & Close</button>'
		+ '<button class="slds-button slds-button_neutral slds-float_right" onclick="saveOEForSelectedConfigs(false)">Save</button>'
		+ '</div>';
	}

	var container = document.getElementsByClassName('container');
	container[0].innerHTML = table.trim();
	container[0].style.padding = "15px";
	prepareDeliveryDetails();

	//crdHtml = await prepareOETable('Customer requested Dates Mobility');
	crdHtml = await prepareOETable('Customer requested Dates');
	//fHtml = await prepareOETable('Mobility features');

	document.getElementById('oe-tab-default-2__item').click();
	document.getElementById('oe-tab-default-1__item').click();
}