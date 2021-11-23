({
	doInit : function(component, event, helper) {
        var conID = component.get("v.pageReference").state.conIDURL;
        var conLookup = component.find("contactLookup");
        var hiddenAddressType = component.get("v.hiddenAddressType");
        var hiddenContactId = component.get("v.hiddenContactId");
        var hiddenAddressId = component.get("v.hiddenAddressId");
        var hiddenActive = component.get("v.hiddenActive");
		var hiddenPrimary =component.get("v.hiddenPrimary");
        if(conID != null){
            //prepopulate contact from url
            conLookup.set("v.value", conID);
            component.set("v.hiddenContactId",conID);
        } else if( hiddenContactId!= null){
            //prepopulate contact in AddressRel after saving address from EAST
            conLookup.set("v.value", hiddenContactId);
        }
        if(hiddenAddressType != null){
            //prepopulate AddressRelName in AddressRel after saving address from EAST
            component.find("addressType").set("v.value",hiddenAddressType);
        }
        if(hiddenAddressId != null){
            //prepopulate address in AddressRel after saving address from EAST
            helper.populateAddress(component, event, helper);
        }
        component.find("btnSaveNew").set("v.disabled",false);
        component.find("btnSave").set("v.disabled",false);
    },
    saveAddressRel : function(component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        //if all the mandatory fields are entered
       	//event.getSource().set("v.disabled", true);
        component.find("btnSave").set("v.disabled",true);
        component.find("btnSaveNew").set("v.disabled",true);
        var addressType = component.find("addressType").get("v.value");
		//if all the mandatory fields are entered
        if(!addressType){
           component.find("addressType").showHelpMessageIfInvalid();
           //event.getSource().set("v.disabled", false);
           component.find("btnSave").set("v.disabled",false);
           component.find("btnSaveNew").set("v.disabled",false);
        }
        else if(component.find("addressLookup").get("v.value") == null) {
            component.find("addressLookup").showError('Please select an address');
            //event.getSource().set("v.disabled", false);
            component.find("btnSave").set("v.disabled",false);
            component.find("btnSaveNew").set("v.disabled",false);
        }
        else if(component.find("addressLookup").get("v.value")!= null){
            helper.saveAddressRel(component, event, helper);
        }
    },
    loadOptions: function (component, event, helper) {
         component.set("v.options", opts);
    },
    loadAddressStatus : function(component,event,helper){
        
    },
    cancelAddressRelCreation : function(component, event, helper) {
        helper.showContactPage(component,event,helper);
    },
    getConAddressTypes: function (component, event, helper) {
        helper.getContactAddressType(component, event, helper);
    },
    navigateToSearchAddress1 : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:SearchAddress",
            componentAttributes: {
                inputAddress : event.getParam("inputText") ,
                hiddenAddressType : component.find("addressType").get("v.value") ,
                hiddenContactId : component.find("contactLookup").get("v.value") ,
                hiddenNavigator : 'ContactAddressRelCreate'
            }
        });
        evt.fire();
    },
    onChange : function(component, event, helper) {
        var addressType =component.find("addressType").get("v.value");
        if(addressType){
            helper.onChangeHelper(component, event, helper);
        }
    }
})