({
	showSpinner: function (component, event, helper) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
	},

	hideSpinner: function (component, event, helper) {
		var spinner = component.find("mySpinner");
		$A.util.addClass(spinner, "slds-hide");
	},
    
    showRedirectSpinner: function (component, event, helper) {
		var spinner = component.find("mySpinner");
		$A.util.removeClass(spinner, "slds-hide");
	},
	closeModal: function (component, event) {
		$('.modal-header').find('.btn-wrapper').find('.btn').click();
	},

	//to show error box
	showToast: function (type, message) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"type": type,
			"key": "action:announcement",
			"message": message
		});
		toastEvent.fire();
	},
	//to fetch Account breadcrumbs
	getAccountDetails: function (component, event, helper) {
		var basketId = component.get('v.basketId');
		var accountId = component.get('v.accountId');

		var action = component.get("c.getAccountDetails");
		action.setParams({
			"basketId": basketId,
			"accountId": accountId
		});
		action.setCallback(this, function (response) {
			var acc = response.getReturnValue();
			component.set("v.acc", acc);
			component.set("v.accountId", acc.Id);
		});
		$A.enqueueAction(action);
	},
	addSelectedHelper: function (component, event, addRecordsIds, changeType, isNonCwpAdded) {
		component.set("v.showSpinner", true);
		var helper = this;
		//call apex class method
		var action = component.get('c.addRecords2');
		var basketId = component.get('v.basketId');
		var accountId = component.get('v.accountId');
		var accountName = component.get('v.acc.Name');
		// pass the all selected record's Id's and Basket Id to apex method
		action.setParams({
			//"lstRecordId": addRecordsIds,
			"solutionIdList": addRecordsIds,
			"basketId": basketId,
			"changeType": changeType,
			"accountId": accountId,
			"accountName": accountName
		});
		action.setCallback(this, function (response) {
			//show loading spinner
			helper.showSpinner(component);
			//store state of response
			var state = response.getState();
			helper.showCustomToast(component, "err1", "error", "error");
			component.set("v.showSpinner", false);
			helper.showCustomToast(component, "err2", "error", "error");
			if (state === "SUCCESS") {
				//hide the loading spinner
				helper.hideSpinner(component);
				// Navigate back to the record view
				var returnedBasketId = response.getReturnValue();
				//helper.closeModal(component, event);
				console.log('returnedBasketId'+returnedBasketId);
				//var test = $A.get("$Label.c.MAC_Success"); 
				if (returnedBasketId != null) {
					helper.hideSelection(component, addRecordsIds, changeType, isNonCwpAdded); //hide selected rows
					helper.showCustomToast(component, "Solution was sucessfully added", "Success", "success");
					let redirect = false;
					if (basketId != returnedBasketId && accountId != '') {
						redirect = true; //redirect to product basket?
					}

					if (changeType == 'Modify') {
						helper.openModifyModalWindow(component, redirect, returnedBasketId);
					} else if (changeType == 'Cancel') {
						helper.openCancelModalWindow(component, redirect, returnedBasketId);
					}
				} else {
					component.set("v.type", 'error');
					helper.showCustomToast(component, 'Error occured during ' + changeType + ' process.', "Adding Solution Error1", "error");
				}
			} else if (state === "ERROR") {

				component.set("v.type", 'error');
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						helper.showCustomToast(component, errors[0].message, "Adding Solution Error2", "error");
						//helper.showToast('error',$A.get("$Label.c.MAC_Error")+' '+errors[0].message);
					}
				} else {
					component.set("v.message", 'Request Failed!');
				}
			}
		});

		$A.enqueueAction(action);
	},

	openCancelModalWindow: function (component, redirect, basketId) {
		component.set("v.basketId", basketId);
		component.set("v.redirectToBasket", redirect);
		component.set("v.showCancellationModal", true);
	},
	openModifyModalWindow: function (component, redirect, basketId) {
		component.set("v.basketId", basketId);
		component.set("v.redirectToBasket", redirect);
		component.set("v.showModifyModal", true);
	},
	closeCancelModalWindow: function (component) {
		component.set("v.showCancellationModal", false);
	},
	closeModifyModalWindow: function (component) {
		component.set("v.showModifyModal", false);
	},
	openAlertforAllCWP: function (component, event) {
		component.set("v.showAlertforAllCWP", true);
		var helper = this;

	},
	closeAlertforAllCWP: function (component) {
		component.set("v.showAlertforAllCWP", false);
	},

	redirectToProductBasket: function (component, basketId) {
		var navigateEvent = $A.get("e.force:navigateToSObject");
		navigateEvent.setParams({
			"recordId": basketId,
			"slideDevName": "detail",
			"isredirect": "true"
		});
		navigateEvent.fire();
	},

	hideSelection: function (component, subscriptionIdList, changeType, isNonCwpAdded) {
		//hide selected
		let tabledata = component.get('v.filteredData')

		subscriptionIdList.forEach(function (subsId) {
			for (var i = 0; i < tabledata.length; i++) {
				if (tabledata[i].SubscriptionID === subsId)
					tabledata.splice(i, 1);
			}
		});
		component.set("v.filteredData", tabledata);
		//update cwpCount
		let cwpCount = 0;
		tabledata.forEach(function (record) {
			if (record.isCWP == true) {
				cwpCount++;
			}
			component.set("v.totalNumberOfCwpRows", cwpCount);
		});

		if (changeType == 'Modify') {
			let numberOfCwpRowsUnderModify = component.get("v.numberOfCwpRowsUnderModify");
			numberOfCwpRowsUnderModify = numberOfCwpRowsUnderModify + subscriptionIdList.length;

			if (isNonCwpAdded == true) {
				numberOfCwpRowsUnderModify = numberOfCwpRowsUnderModify - component.get('v.nonCwpData').length;
			}
			component.set("v.numberOfCwpRowsUnderModify", numberOfCwpRowsUnderModify);
		}

		if (isNonCwpAdded == true) component.set('v.nonCwpData', []);
	},

	validateSelection: function (component, event, selectedRecordList) {
		let totalNumberOfRows = component.get("v.totalNumberOfActiveCwpRows");
		let CwpRowsUnderModifyInBasket = component.get("v.CwpRowsUnderModifyInBasket");
		let selectedCWPItems = component.get("v.selectedCWPCount");
		totalNumberOfRows = totalNumberOfRows - selectedCWPItems + CwpRowsUnderModifyInBasket;
		if (totalNumberOfRows <= 0) {
			component.set("v.flagAllCWPForCancel", true);
			return true;
		} else if (totalNumberOfRows >= 2) {
			return true;
		}

		return false;
	},

	showCustomToast: function (cmp, message, title, type) {
		$A.createComponent(
			"c:customToast", {
				"type": type,
				"message": message,
				"title": title
			},
			function (customComp, status, error) {
				if (status === "SUCCESS") {
					var body = cmp.find("container");
					body.set("v.body", customComp);
				}
			}
		);
	},
	getColumnDefinitions: function () {
		//var columnsWidths = this.getColumnWidths();
		var columns = [{
				label: 'SUBSCRIPTION NAME',
            fieldName: 'subscriptionNameLink',
            type: 'url',
            sortable: true,
            typeAttributes: {
                label: {
                    fieldName: 'subscriptionName'
                },
                target: '_blank'
            }
        },
                       {
				label: 'Site',
				fieldName: 'site',
				type: 'text',
				sortable: true
			},
			{
				label: 'Created Date',
				fieldName: 'createdDate',
				type: 'text',
				sortable: true
			},
			{
				label: 'Status',
				fieldName: 'status',
				type: 'text',
				sortable: true
			},
			{
				label: 'Total Recurring Charges',
				fieldName: 'totalRC',
				type: 'text',
				sortable: true
			},
			{
				label: 'Total One-Off Charges',
				fieldName: 'totalOC',
				type: 'text',
				sortable: true
			},
			{
				label: 'Total Contract Value',
				fieldName: 'totalCV',
				type: 'text',
				sortable: true
			},
			{
				label: 'Created By',
				fieldName: 'createdBy',
				type: 'text',
				sortable: true
			},
		];
		return columns;
	},
	sortData: function (cmp, fieldName, sortDirection) {
		var data = cmp.get("v.filteredData");
		var reverse = sortDirection !== 'asc';

		data = Object.assign([],
			data.sort(this.sortBy(fieldName, reverse ? -1 : 1))
		);
		cmp.set("v.filteredData", data);
	},
    getCurrentUserProfile: function(component, event, helper){
        
        var action = component.get("c.getCurrentUserProfile");
        action.setCallback(this, function (response) {
			var profilename= response.getReturnValue();
            if(profilename=='Assurance Service Agent'){	
                component.set("v.assuranceProfileFlag", "true");
            }
            else {
                component.set("v.assuranceProfileFlag", "false");
            }
            //EDGE-172345 start
            if(profilename=='Sales-Enterprise-Unified'){//
                component.set("v.isSalesEnterpriseUnified", "true");
            }
            //EDGE-172345 end
            //EDGE-202389 start
            if(profilename=='Billing Consultant'){//
                component.set("v.isBillingConsultant", "true");
            }
            //EDGE-202389 end			
            console.log('@@v.assuranceProfileFlag@@'+ component.get("v.assuranceProfileFlag"));
            console.log('@@v.profilename@@'+ profilename);
		});
		$A.enqueueAction(action);
        
    },
	sortBy: function (field, reverse, primer) {
		var key = primer ?
			function (x) {
				return primer(x[field])
			} :
			function (x) {
				return x[field]
			};

		return function (a, b) {
			var A = key(a);
			var B = key(b);
			return reverse * ((A > B) - (B > A));
		};
	},
	disableBtnCheck: function(component, event, helper){
        var disablebtn;
        var conObj = component.get("v.selectedLookUpRecord");
        console.log('selectedLookUpRecord: '+ component.get('v.selectedLookUpRecord'));
        if(conObj.ContactId == undefined){
            disablebtn = true;
        }
        else{
            disablebtn = false;
        }
        component.set('v.disablebtn', disablebtn);
        component.find('showSolutionLWCComponent').methodtoGetDisablebtn(disablebtn);
	},
	navigationHanlder: function(component, event, helper){
               
		var oppId = component.get('v.opportunityId');
        var basketId = component.get('v.basketId');
        var retry = true;
        component.set("v.showRedirectSpinner", true);
        var refreshIntervalId = window.setInterval(checkJobStatus,10000);		
        function checkJobStatus() {
            
            if (retry){
                retry = false;
            		var action = component.get("c.getJobStatus");
				action.setParams({
					"OpptyId": oppId,
				});
		
				action.setCallback(this, function (response) {
                    retry = true;
					var state = response.getState();
					if (state === "SUCCESS") {
					var status = response.getReturnValue();
                        if (status == 'SUCCESS'){
                            clearInterval(refreshIntervalId);
                            component.set("v.showRedirectSpinner", false);
						var navigateEvent = $A.get("e.force:navigateToSObject");
						navigateEvent.setParams({
							"recordId": basketId,
							"slideDevName": "detail",
							"isredirect": "true"
						});

						navigateEvent.fire();
                        }
													}
				});
				$A.enqueueAction(action);
        }

		}
        

	},
	validateContactRecordandSelectedSolution: function(component,event,recordSize,helper,solName,isBillingaccvalid){
		var isValid = true;
        var selActType = component.get('v.actionTypeSelected');//DIGI-9239
		console.log('Inside validateContactRecordandSelectedSolution',recordSize+' '+solName);
        if(!isBillingaccvalid){ ////EDGE-147513 added by shubhi
            helper.showCustomToast(component,$A.get("$Label.c.BillingAccountwarning"), "Warning: ","warning");
        }
		component.set("v.isError1", false);
        if(selActType != 'Insolvency Cancel'){
			//EDGE-95594 --> Check Modify Requestor  is selected or not
			var conObj = component.get("v.selectedLookUpRecord");
			if (conObj != null || conObj != undefined) {
				if ((conObj.Roles == undefined) || (conObj.Roles == '')) {
					//component.set("v.showSpinner1", false);
				//	component.set("v.isError1", true);
					isValid = false;
					helper.showCustomToast(component,$A.get("$Label.c.User_Not_Authorized"), "Requester Error: ","error");
					component.set("v.showRedirectSpinner", false);
				} else if ((conObj.Roles != "Full Authority") && (conObj.Roles != "Legal Lessee")) {
					//EDGE-95594 --> Throw Error is accurate role is not selected
					conObj = null;
					isValid = false;
					component.set("v.showRedirectSpinner", false);
					helper.showCustomToast(component, $A.get("$Label.c.User_Not_Authorized"), "Requester Error: ","error");
				}
			} else {
				component.set("v.showRedirectSpinner", false);
				helper.showCustomToast(component, $A.get("$Label.c.User_Not_Authorized"), "Requester Error: ","error");
				isValid = false;
			}
		//}
			console.log('isValid   ',isValid);
			//DPG-1915- start- check for Adaptive Care solution
            if(solName=='Next Gen Mobility Adaptive Care')
            {
                var accountId= component.get('v.accountId');
                console.log('inside validateAEPartnerAccessforAC');
                var action = component.get("c.getUserValidatedForAC");
                action.setParams({
                    "accountId": accountId                        
                });		
                action.setCallback(this, function (response) { 
                    console.log('inside response');
                    var state = response.getState();
                    console.log('state --->',state);
                    if (state ==="SUCCESS") {
                        var status = response.getReturnValue();
                        if(status==true)
                        {
                            //DPG- 1915-- moved inside the if condition.
                component.find('showSolutionLWCComponent').addSolutionOrSkip(isValid,conObj.ContactId);
                        }
                        else{
                            component.set("v.showRedirectSpinner", false);
                            helper.showCustomToast(component, $A.get("$Label.c.User_Not_Authorized_Cancel"), "Requester Error: ","error");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
            else
            {
                component.find('showSolutionLWCComponent').addSolutionOrSkip(isValid,conObj.ContactId);
            }
        }//Insolvency Cancel
        else{
            component.find('showSolutionLWCComponent').addSolutionOrSkip(isValid,'dummy');//EDGE-9239
        }
        //DPG-1915- end
    },
    //EDGE-154023  add solution logic by shubhi start-----------
    disableAddBtnCheck: function(component, event, helper){
    var disableAddbtn;
    	var conObj = component.get("v.selectedLookUpRecord");
        if(conObj.ContactId == undefined){
            disableAddbtn = true;
        }
        else{
            disableAddbtn = false;
        }
    	component.set('v.disableAddbtn', disableAddbtn);
        component.find('showSolutionLWCComponent').methodtoGetDisablebtn(disableAddbtn);
	},
    validateContactRecordforAddsolution: function(component,event,recordSize,helper,isBillingaccvalid){
        var isValid = true;
        var conObj = component.get("v.selectedLookUpRecord");
        if (conObj != null || conObj != undefined) {
            if ((conObj.Roles == undefined) || (conObj.Roles == '')) {
                isValid = false;
                helper.showCustomToast(component,$A.get("$Label.c.User_Not_Authorized"), "Requester Error: ","error");
                component.set("v.showRedirectSpinner", false);
            } else if ((conObj.Roles != "Full Authority") && (conObj.Roles != "Legal Lessee")) {
                conObj = null;
                isValid = false;
                helper.showCustomToast(component, $A.get("$Label.c.User_Not_Authorized"), "Requester Error: ","error");
                component.set("v.showRedirectSpinner", false);
            }
        }
		component.find('showSolutionLWCComponent').addNewSolution(isValid,conObj.ContactId);
    }
    //EDGE-154023  add solution logic by shubhi end-----------
})