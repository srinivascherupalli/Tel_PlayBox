({
	saveAddressRel : function(component, event, helper) {
		var addressType = component.find("addressType").get("v.value");
        var account = component.find("accountLookup").get("v.value");
        var address = component.find("addressLookup").get("v.value");
        var active  = component.find("hiddenActive").get("v.value");
        var action = component.get("c.saveNewAddressRel");
        action.setParams({"addressType" : ''+ addressType, "account" : ''+account,"address" : ''+address,"active" : ''+active});
        action.setCallback(this, function(response) {
            var data = JSON.parse(response.getReturnValue()); 
            
            if(data.isSuccess == false){
                component.find("btnSave").set("v.disabled",false);
                component.find("btnSaveNew").set("v.disabled",false);
                this.showToast(component, event, 'Failure',data.errorMsg,'error');    
            }else{
                this.showToast(component, event, 'Success', data.successMsg, 'success');
                if(event.getSource().get("v.value") == "saveandnew"){
                    $A.get("e.force:refreshView").fire();
                }else{
                    this.showCustomerPage(component, event, helper);
                }
            }            
        });
        $A.enqueueAction(action);
    },
    populateAddress : function(component, event, helper){
        component.find("addressLookup").set("v.value",component.get("v.hiddenAddressId"));
    },
    getAddressTypes: function (component, event, helper) {
        var action = component.get("c.getaddressTypes");
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            component.set("v.options", opts);
        });
        $A.enqueueAction(action);
    },
    showCustomerPage : function(component, event, helper) {
        var accountId = component.find("accountLookup").get("v.value");
        $A.get("e.force:refreshView").fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": accountId
        });
        navEvt.fire();
    },
    isAddressTypeAvailable : function(component, event, helper){
        var action = component.get("c.hasAddress");
        var addressType = component.find("addressType").get("v.value");
        var account = component.find("accountLookup").get("v.value");
        action.setParams({"addressType" : ''+ addressType, "account" : ''+account});
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!opts){
                    this.showToast(component,event,addressType,$A.get("$Label.c.Address_Error"),'error');   
                }
                component.find("hiddenActive").set("v.value",opts);
                component.find("hiddenActive").set("v.disabled",!opts);               
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast(component,event,addressType,errors[0].message,'error'); 
                    }
                } else {
                    this.showToast(component,event,addressType,'Unknown Error','error'); 
                }
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(component, event, title ,msg,msgType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 5000,
            "title": title,
            "message": msg,
             type : msgType
        });
        toastEvent.fire();
	}
})