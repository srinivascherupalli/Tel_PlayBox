({
	doInit : function(component, event, helper) {
        var accID = component.get("v.pageReference").state.accIDURL;
        var accLookup = component.find("accountLookup");
        var hiddenAddressType = component.get("v.hiddenAddressType");
        var hiddenAccountId = component.get("v.hiddenAccountId");
        var hiddenAddressId = component.get("v.hiddenAddressId");
        var hiddenActive = component.get("v.hiddenActive");
        if( hiddenAccountId!= null){
            //prepopulate Account in AddressRel after saving address from EAST
            accLookup.set("v.value", hiddenAccountId);
        }
        else if(accID != null){
            //prepopulate Account from url
            accLookup.set("v.value", accID);
            component.set("v.hiddenAccountId",accID);
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
        }else if(component.find("addressLookup").get("v.value") == null) {
            component.find("addressLookup").showError('Please select an address');
            //event.getSource().set("v.disabled", false);
            component.find("btnSave").set("v.disabled",false);
            component.find("btnSaveNew").set("v.disabled",false);
        }else if(component.find("addressLookup").get("v.value")!= null){
            helper.saveAddressRel(component, event, helper);
        } 
    },
    loadOptions: function (component, event, helper) {
         component.set("v.options", opts);
    },
    cancelAddressRelCreation : function(component, event, helper) {
		helper.showCustomerPage(component, event, helper);
    },
    getAddressTypes: function (component, event, helper) {
        helper.getAddressTypes(component, event, helper);
    },
    navigateToSearchAddress1 : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:SearchAddress",
            componentAttributes: {
                //for US-3971
                inputAddress : event.getParam("inputText") ,
                //end
                hiddenAddressType : component.find("addressType").get("v.value") ,
                hiddenAccountId : component.find("accountLookup").get("v.value") ,
                hiddenNavigator : 'AddressRelCreate'
            }
        });
        evt.fire();
    },
    isAddressAvailable : function(component, event, helper){
        var addressType = component.find("addressType").get("v.value");
        if(addressType){
            helper.isAddressTypeAvailable(component,event,helper);
        }
    }
})