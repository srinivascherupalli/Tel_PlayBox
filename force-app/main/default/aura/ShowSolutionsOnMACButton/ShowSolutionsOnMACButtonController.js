({
	doInit: function (component, event, helper) {

		component.set("v.showSpinner", true);
		helper.getAccountDetails(component, event, helper);
		helper.getCurrentUserProfile(component, event, helper);
		component.set('v.columns', helper.getColumnDefinitions());
		component.set('v.keyField', "SolutionID");
		var basketId = component.get('v.basketId');
		var accountId = component.get('v.accountId');
        var selActType = component.get('v.actionTypeSelected');//DIGI-9239
		component.set('v.accIdset', true);
		console.log('accountId ' + accountId);
		console.log('basketId ' + basketId);
		console.log('selected-->' + JSON.stringify(component.get('v.selectedLookUpRecord')));
		if (basketId != null && basketId != "" && selActType != 'Insolvency Cancel') {
			var action = component.get("c.getACRId");
			action.setParams({
				"basketId": basketId,
			});
			action.setCallback(this, function (response) {
				var acr = response.getReturnValue();
				component.set('v.selectedLookUpRecord', acr)
			});
			$A.enqueueAction(action);
		}

		
		var action = component.get("c.getSolutionView");
		action.setParams({
			"basketId": basketId,
			"accountId": accountId
		});
		action.setCallback(this, function (response) {
			var state = response.getState();
			component.set("v.showSpinner", false);
			if (state === "SUCCESS") {
				var records = response.getReturnValue();
				if (records.length == 0) {
					component.set("v.isListNotPresent", "true");
				} else {
					let nonCwpCount = 0;
					let activeCwpCount = 0;
					let mobilityCount = 0;
					let nonCwpList = [];
					let mobilityList = [];
					records.forEach(function (record) {
					
						if (record.SolutionName.includes("Connected Workplace") && record.status == 'Active') {
							activeCwpCount++;
						}
					});
					component.set("v.totalNumberOfActiveCwpRows", activeCwpCount);
					//component.set("v.totalNumberOfCwpRows", records.length - nonCwpCount - mobilityCount);
					//component.set("v.nonCwpData", nonCwpList);
					//component.set("v.mobilityData", mobilityList);
					//component.set("v.numberOfMobilityProducts", mobilityCount);
				}

				records.forEach(function (record) {
					record.solutionNameLink = '/' + record.SolutionID;
					//if (record.SiteID != null) {
					//record.siteAddressLink = '/' + record.SiteID;
					//}
				});

				component.set("v.data", records);
				component.set("v.filteredData", records);
				//component.set("v.wrapList",rows);
				//component.find("box3").set("v.value", false);
			} else if (state === "ERROR") {
				var errors = response.getError();
				helper.showCustomToast(component, errors, "Initialization Error", "error");
				//console.error(errors);
			}
		});
		$A.enqueueAction(action);
	},

	// For count the selected checkboxes. 
	updateSelectedText: function (component, event, helper) {
		var dTable = component.find("solutionTable");
		var selectedRowsArray = dTable.getSelectedRows();
		var finalselection = [];
		var addId = [];
		let selectedCWP = 0;
		for (var i = 0; i < selectedRowsArray.length; i++) {
               addId = [];
			if (selectedRowsArray[i] != null) {
				if (selectedRowsArray[i].SolutionName.includes('Connected Workplace')) {
					selectedCWP++;
				}
				var disableRow;
				
				
				//[Brahm][EDGE-123942][AC-5 temporary implementation] [Start]
				if (selectedRowsArray[i].disableRow == true && selectedRowsArray[i].SolutionName.includes('Professional Services')) {
				}
				else
					addId.push(selectedRowsArray[i].SolutionID);
				 //[Brahm][EDGE-123942][AC-5 temporary implementation] [End]
			}
		}
		component.set("v.selectedCWPCount", selectedCWP);
		component.set('v.selectedRowsCount', addId.length);
		component.set('v.selectedRows', addId);
		helper.disableBtnCheck(component, event, helper);
		/*if (addId.length > 1) { //commented as part od EDGE-138655
			helper.showCustomToast(component, "Only one Solution can be selected.", "Selected Solution: " + JSON.stringify(finalselection[0]), "warning");
		}*/
		if (finalselection.length != 0) {
			helper.showCustomToast(component, "Only Active CWP Solution can be selected. Please select valid Solution.", "Selected Solution: " + JSON.stringify(finalselection[0]), "warning");
		}
		finalselection = [];

		component.set('v.SelectedSolID', addId);
	},
onCancel: function (component, event, helper) {
	// Navigate back to the record view
	var accountId = component.get('v.accountId');

	var navigateEvent = $A.get("e.force:navigateToSObject");
	navigateEvent.setParams({
		"recordId": accountId,
		"slideDevName": "detail",
		"isredirect": "true"
	});

	navigateEvent.fire();
	//helper.showCustomToast(component, "Something broke", "Error Title", "error");
},
onModify: function (component, event, helper) {
	// Navigate back to the record view
	var accountId = component.get('v.accountId');

	var navigateEvent = $A.get("e.force:navigateToSObject");
	navigateEvent.setParams({
		"recordId": accountId,
		"slideDevName": "detail",
		"isredirect": "true"
	});

	navigateEvent.fire();
	//helper.showCustomToast(component, "Something broke", "Error Title", "error");
},

showSpinner: function (component, event, helper) {
	// make Spinner attribute true for display loading spinner 
	component.set("v.Spinner", true);
},

hideSpinner: function (component, event, helper) {
	// make Spinner attribute to false for hide loading spinner    
	component.set("v.Spinner", false);
},

showRedirectSpinner: function (component, event, helper) {
	// make Spinner attribute true for display loading spinner 
	component.set("v.Spinner", true);
},
updateColumnSorting: function (component, event, helper) {
	component.set('v.isLoading', true);
	// We use the setTimeout method here to simulate the async
	// process of the sorting data, so that user will see the
	// spinner loading when the data is being sorted.
	setTimeout(function () {
		var fieldName = event.getParam('fieldName');
		var sortDirection = event.getParam('sortDirection');
		component.set("v.sortedBy", fieldName);
		component.set("v.sortedDirection", sortDirection);
		helper.sortData(component, fieldName, sortDirection);
		component.set('v.isLoading', false);
	}, 0);
},
filter: function (component, event, helper) {
	var data = component.get("v.data"),
		term = component.get("v.filter"),
		results = data,
		regex;
	try {
		regex = new RegExp(term, "i");
		// filter checks each row, constructs new array where function returns true
		results = data.filter(row => regex.test(row.SolutionName) ||
			regex.test(row.status) || regex.test(row.totalRC) ||
			regex.test(row.totalOC) || regex.test(row.totalCV) ||
			regex.test(row.createdBy) || regex.test(row.createdDate)|| regex.test(row.site));
	} catch (e) {
		// invalid regex, use full list
	}
	component.set("v.filteredData", results);
	var data1 = component.get("v.filteredData")
	if (data1.length == 0) {
		component.set('v.NoSearchRecord', true);
	}
	if (data1.length != 0) {
		component.set('v.NoSearchRecord', false);
	}
},

handleCancelReasonUpdate: function (component, event, helper) {
	var redirect = event.getParam("redirect");
	helper.closeCancelModalWindow(component);
	if (redirect == true) {
		let basketId = component.get("v.basketId");
		helper.redirectToProductBasket(component, basketId);
	}
},
handleModifyReasonUpdate: function (component, event, helper) {
	var redirect = event.getParam("redirect");
	helper.closeModifyModalWindow(component);
	if (redirect == true) {
		let basketId = component.get("v.basketId");
		helper.redirectToProductBasket(component, basketId);
	}
}
/*,
handleContactandSelectedSolutionValidation: function(component, event, helper){

	helper.validateContactRecordandSelectedSolution(component,)
}*/,
handleLwcCompleteJob: function (component, event, helper){
	
	var filters = event.getParam('bID');
	var oppID = event.getParam('OppId');
	component.set("v.basketId",filters);
    var navigateEvent = $A.get("e.force:navigateToSObject");
    navigateEvent.setParams({
        "recordId": filters,
        "slideDevName": "detail",
        "isredirect": "true"
    });
	navigateEvent.fire();
	component.set("v.showRedirectSpinner", false);

},
handleLwcChangeSolution: function (component, event, helper) {
	component.set("v.showRedirectSpinner", true);
	//DPG-1915-start//
    var solName= event.getParam('solName');
    console.log('Solution Name' , solName);
    //DPG-1915-end
	var recordSize = parseInt(event.getParam('lenghtofrecord'));
    var isBillingaccvalid=event.getParam('isBillingaccvalid');////EDGE-147513 added by shubhi
	console.log('isBillingaccvalid--'+isBillingaccvalid);
	helper.validateContactRecordandSelectedSolution(component,event,recordSize,helper, solName,isBillingaccvalid);
	
},
    //EDGE-154023 added add solution logic by shubhi
handleLwcAddSolution: function (component, event, helper) {	
	component.set("v.showRedirectSpinner", true);
    console.log('handleLwcAddSolution-----');
	helper.validateContactRecordforAddsolution(component,event,helper);	
},
itemsChange: function (component, event, helper) {
	helper.disableBtnCheck(component, event, helper);
},
handleLwcJobFailed: function (component, event, helper){
	helper.showCustomToast(component, "Basket generation Job Failed ", " Job Failed: ","error");
	component.set("v.showRedirectSpinner", false);
},
openModalPopup: function (component, event, helper){
	var solId = event.getParam('solID');
	component.set("v.solutionId", solId);
	component.set("v.isOpen", true);
},
click: function (component, event, helper){
    alert('in click function');    
},

/*,
handleAlertCancelAllCWP: function (component, event, helper) {
	var redirect = event.getParam("proceed");
	helper.closeAlertforAllCWP(component);
	if (redirect == false) {
		component.set("v.showAlertforAllCWP", false);
		component.set("v.proceedAfterAllCWPAlert", false);
	} else {
		var a = component.get("c.cancelSelected");
		component.set("v.proceedAfterAllCWPAlert", true);
		$A.enqueueAction(a);
	}
}*/
})