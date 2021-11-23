/****************************************************************************
@Name: LimitedAuthority
@Author: Sri & Sravanthi(Team SFO)
@CreateDate: 14/04/2020
@Description: Sprint 20.04 ; P2OB-4922
*****************************************************************************/
({
//Modified as part P2OB-6398,Sprint 20.08,As a Sales User, I want to no longer see the "Authorised CIDNS" in the Limited Authority Management custom component
	//This function retrieves CIDNs and Child cidns from the related Account hierarchy for this Contact
	  /* getCIDNs: function (component, event, helper) {
		var actionCIDN = component.get("c.getCIDNs");
		actionCIDN.setParams({
			contactId: component.get("v.recordId"),
		});

		actionCIDN.setCallback(this, function (response) {
			var state = response.getState();
			component.set('v.IsSpinner',false);
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				var cidnValues = [];
				for (var i = 0; i < result.length; i++) {
					cidnValues.push({
						label: result[i],
						value: result[i]
					});
				}
				component.set("v.CIDNList", cidnValues);
			}
		});
		$A.enqueueAction(actionCIDN);
	},
	//This function is used to acheive the multiselect picklist funationality
    selectOption: function (component, event, helper) {
        var label = event.currentTarget.id.split("#BP#")[0];
        var isCheck = event.currentTarget.id.split("#BP#")[1];
        var selectAllIsChecked = component.get("v.selectall");
        var selectedOption = '';
        var allselectedCIDNs = '';
        var allOptions = component.get('v.CIDNList');
        var count = 0;
        for (var i = 0; i < allOptions.length; i++) {
            if (allOptions[i].label == label) {
                if (isCheck == 'true') {
                    allOptions[i].isChecked = false;
                    if (selectAllIsChecked) {
                        component.set('v.selectall', false);
                    }
                }
                else {
                    allOptions[i].isChecked = true;
                }
            }
            if (allOptions[i].isChecked) {
                selectedOption = allOptions[i].label;
                count++;
            }
        }
        if (count > 0) {
            selectedOption = count + ' items selected';
        }
        // component.set('v.selectedCIDNList',allselectedCIDNs);
        component.set("v.selectedOptions", selectedOption);
        component.set('v.CIDNList', allOptions);
	},
	//This function is used to acheive the select all picklist funationality
    selectALLOption: function (component, event, helper) {
        var selectAllIsChecked = component.get("v.selectall");
        var allOptions = component.get('v.CIDNList');
        for (var i = 0; i < allOptions.length; i++) {
            if (selectAllIsChecked) {
                allOptions[i].isChecked = false;
            }
            else {
                allOptions[i].isChecked = true;
            }

        }
        component.set('v.CIDNList', allOptions);
        if (selectAllIsChecked) {
            component.set('v.selectall', false);
            component.set("v.selectedOptions", '')
        }
        else {
            component.set('v.selectall', true);
            component.set("v.selectedOptions", (allOptions.length + ' items selected'));
        }
	},END Modified as part P2OB-6398*/
	//This funcation is used to loads the saved values to fields in componet
	handleOnLoad: function (component, event, helper) {
//Modified as part P2OB-6398,Sprint 20.08,As a Sales User, I want to no longer see the "Authorised CIDNS" in the Limited Authority Management custom component
		/*var savedcidns = component.get('v.contactRecord.Authorised_CIDNs__c');
		var allOptions = component.get('v.CIDNList');
		component.set('v.showAuthorisedCIDNs', component.get('v.contactRecord.Order_Services__c'));
		component.set('v.showAuthorisedBillingAccounts', component.get('v.contactRecord.Raise_Billing_Disputes__c'));

		if (savedcidns) {
			var authorisedcidns = savedcidns.split(",");
			var selectedcidns = [];
			for (var i = 0; i < authorisedcidns.length; i++) {
				selectedcidns.push(authorisedcidns[i]);
			}
			if (selectedcidns.length > 0) {
				component.set("v.selectedOptions", (selectedcidns.length + ' items selected'));
			}
		} END Modified as part P2OB-6398*/
		helper.showSpinner(component, false);
	},
	//This funcation is used to show the toast message
	showToast: function (title, message, type) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"message": message,
			"type": type
		});
		toastEvent.fire();
	},
	//This funcation is used to show the Spinner
	showSpinner: function (component, isSpinner) {
		component.set('v.IsSpinner', isSpinner);
	},
	//This funcation is used to submit the record
	handleOnSubmit: function (component, event, helper) {
		event.preventDefault();
		helper.showSpinner(component, true);
		var fields = event.getParam('fields');
		var errorMsg = ''
		var errorMsgCode = 'FIELD_CUSTOM_VALIDATION_EXCEPTION'
		//:: START :: Checking Order Services and Authorised CIDNs
		var cidnlabel = '';
		if (fields.Order_Services__c) {
			var allOptions = component.get('v.CIDNList');
			for (var i = 0; i < allOptions.length; i++) {
				if (allOptions[i].isChecked) {
					cidnlabel += allOptions[i].label.split(' ::')[0] + ',';
				}
			}
		} else cidnlabel = '';
		cidnlabel = cidnlabel.slice(0, cidnlabel.length - 1);
		fields.Authorised_CIDNs__c = cidnlabel;
		//:: END :: Checking Order Services and Authorised CIDNs

		//:: START :: Checking RaiseBillingDisputes and Authorised Billing Accounts
		var billingAccNums;
		var billingAccNumRegEx = /^(\d{10}|\d{13})$/g;
		if (fields.Raise_Billing_Disputes__c && fields.Authorised_Billing_Accounts__c) {
			billingAccNums = fields.Authorised_Billing_Accounts__c.split(',');
			for (var i = 0; i < billingAccNums.length; i++) {
				if (!(billingAccNums[i].trim()).match(billingAccNumRegEx)) {
					helper.showSpinner(component, false);
					errorMsg += $A.get("$Label.c.Contact_BillingAccNum_Format");
					break;
				}

			}
		} else if (!fields.Raise_Billing_Disputes__c) fields.Authorised_Billing_Accounts__c = '';

		if (!fields.Report_Service_Incidents__c &&
			!fields.Raise_Billing_Disputes__c &&
			!fields.Order_Services__c) {
			helper.showSpinner(component, false);
			errorMsg += $A.get("$Label.c.Contact_Limited_Authority_ErrorMsg");
		}
		if (errorMsg) {
			helper.showToast(errorMsgCode, errorMsg, "Error");
			return;
		}
		component.find('LAForm').submit(fields);
	},

})