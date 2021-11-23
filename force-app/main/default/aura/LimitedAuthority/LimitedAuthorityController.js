/****************************************************************************
@Name: LimitedAuthority
@Author: Sri & Sravanthi(Team SFO)
@CreateDate: 14/04/2020
@Description: Sprint 20.04 ; P2OB-4922
*****************************************************************************/
({
    //This function calls helper's getCIDNs() to retrieve CIDNs and Child cidns from the related Account hierarchy for this Contact
        doInit: function (component, event, helper) {
        helper.showSpinner(component,true);
//Modified as part P2OB-6398,Sprint 20.08,As a Sales User, I want to no longer see the "Authorised CIDNS" in the Limited Authority Management custom component 
        //helper.getCIDNs(component, event, helper);
    },
    //This function calls helper's handleOnLoad()
    onLoad: function (component, event, helper) {
        helper.handleOnLoad(component, event, helper);
    },
//Modified as part P2OB-6398,Sprint 20.08,As a Sales User, I want to no longer see the "Authorised CIDNS" in the Limited Authority Management custom component 
     //This function used to open the dropdown on Authorised CIDNs picklist
      /*openDropdown: function (component, event, helper) {
        $A.util.addClass(component.find('dropdown'), 'slds-is-open');
        $A.util.removeClass(component.find('dropdown'), 'slds-is-close');
    },
    //This function used to close the dropdown on Authorised CIDNs picklist
        closeDropDown: function (component, event, helper) {
        $A.util.addClass(component.find('dropdown'), 'slds-is-close');
        $A.util.removeClass(component.find('dropdown'), 'slds-is-open');
    },
    //END  Modified as part P2OB-6398,Sprint 20.08
    */
    //This function calls upon the error, and it displays the error messages as toast
    handleOnError: function (component, event, helper) {
        helper.showSpinner(component,false);
        var error = event.getParams();
        var errorMsg = ''
        var errorMsgCode = ''
        error.output.errors.forEach(function (msg) {
                errorMsgCode = msg.errorCode;
                errorMsg +=msg.message +'\n';
            }
        );
        if(errorMsgCode =='INSUFFICIENT_ACCESS'){
            component.set('v.isEdit', false);
        }
        helper.showToast(errorMsgCode, errorMsg, "Error");
    },
    //This function calls on edit button to control the visibility
    onEdit: function (component, event, helper) {
        component.set('v.isEdit', true);
//Modified as part P2OB-6398,Sprint 20.08,As a Sales User, I want to no longer see the "Authorised CIDNS" in the Limited Authority Management custom component
        //component.set('v.showAuthorisedCIDNs', component.get('v.contactRecord.Order_Services__c'));
        component.set('v.showAuthorisedBillingAccounts', component.get('v.contactRecord.Raise_Billing_Disputes__c'));
//Start Modified as part P2OB-6398,Sprint 20.08,As a Sales User, I want to no longer see the "Authorised CIDNS" in the Limited Authority Management custom component
        //var allOptions = component.get('v.CIDNList');
        //ar savedcidns = component.get('v.contactRecord.Authorised_CIDNs__c');
        /*if (savedcidns) {
            var authorisedcidns = savedcidns.split(",");
            var selectedcidns = [];
            for (var i = 0; i < authorisedcidns.length; i++) {
                selectedcidns.push(authorisedcidns[i]);
            }
            for (var i = 0; i < allOptions.length; i++) {
                if (selectedcidns.includes(allOptions[i].label.split(' ::')[0])) {
                    allOptions[i].isChecked = true;
                }
            }
            component.set('v.CIDNList', allOptions);
        }else{
            component.set("v.selectall", true);
            component.set("v.selectedOptions", '');
            helper.selectALLOption(component, event, helper);
        }*/
        //End Modified as part P2OB-6398,Sprint 20.08
    },
    //This function used to control the visibility
    onCancel: function (component, event, helper) {
        component.set('v.isEdit', false);
        //component.set('v.showAuthorisedCIDNs', component.get('v.contactRecord.Order_Services__c'));
        component.set('v.showAuthorisedBillingAccounts', component.get('v.contactRecord.Raise_Billing_Disputes__c'));
    },
    //This function used to control the visibility of OrderServices and RaiseBillingDisputes
    handleOnChange: function (component, event, helper) {
        var eventSourceID = event.getSource().getLocalId();
        if(eventSourceID = 'OrderServices'){
            var OrderServices = component.find('OrderServices').get('v.value');
            component.set('v.showAuthorisedCIDNs', OrderServices)
        }
        if(eventSourceID = 'RaiseBillingDisputes'){
            var RaiseBillingDisputes = component.find('RaiseBillingDisputes').get('v.value');
            component.set('v.showAuthorisedBillingAccounts', RaiseBillingDisputes)
        }
    },
//Modified as part P2OB-6398,Sprint 20.08,As a Sales User, I want to no longer see the "Authorised CIDNS" in the Limited Authority Management custom component
    //This function calls the helper's selectOption()
    /*selectOption: function (component, event, helper) {
        helper.selectOption(component, event, helper);
    },
    //This function calls the helper's selectALLOption()
      selectALLOption: function (component, event, helper) {
        helper.selectALLOption(component, event, helper);
    }, END modified as part P2OB-6398*/
    //This function used to display the succes meesage
    handleOnSuccess: function (component, event, helper) {
        component.set('v.isEdit', false);
        helper.showSpinner(component, false);
        $A.get("e.force:refreshView").fire();
        if($A.get("$Browser.isPhone")){
            helper.showToast("","Contact '"+ component.get('v.contactRecord.Name') +"' was saved","success");
        }
    },
    //This function calls the helper's handleOnSubmit()
    handleOnSubmit: function (component, event, helper) {
        helper.handleOnSubmit(component, event, helper);
    }
});