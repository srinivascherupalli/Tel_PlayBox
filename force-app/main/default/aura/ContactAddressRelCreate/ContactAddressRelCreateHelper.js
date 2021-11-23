({
    saveAddressRel : function(component, event, helper) {
        var addressType = component.find("addressType").get("v.value");
        var contact = component.find("contactLookup").get("v.value");
        var address = component.find("addressLookup").get("v.value");
        var active  = component.find("hiddenActive").get("v.value");
        var isPrimary = component.find("hiddenPrimary").get("v.value");
        var action = component.get("c.saveNewAddressRel");
        action.setParams({"addressType" : ''+ addressType, "contact" : ''+contact,"address" : ''+address,"active" : ''+active,"primary" : ''+isPrimary});
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
                    this.showContactPage(component, event, helper);
                }
            }
        });
        $A.enqueueAction(action);
    },
    populateAddress : function(component, event, helper){
        component.find("addressLookup").set("v.value",component.get("v.hiddenAddressId"));
    },
    getContactAddressType: function (component, event, helper) {
        var action = component.get("c.getContactAddressTypesController");
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            component.set("v.options", opts);
        });
        $A.enqueueAction(action);
    },
    showContactPage : function(component, event, helper) {
        var contactId = component.find("contactLookup").get("v.value");
        $A.get("e.force:refreshView").fire();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": contactId
        });
        navEvt.fire();
    },
    onChangeHelper : function(component, event, helper){
        var addressType =component.find("addressType").get("v.value");
        var contact = component.find("contactLookup").get("v.value");
        var tempContact=null;
        if(contact!=null && contact.includes('&0.source=aloha')){
            tempContact=contact.replace("&0.source=aloha","");            
        }
        else
            tempContact=contact;
        
        var action = component.get("c.hasAddress");
        if(tempContact!=null){
            action.setParams({"addressType" : ''+ addressType, "contact" : ''+tempContact});
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                //alert(data);            
                if(addressType.includes('Home Address') || addressType.includes('Office Address')){
                    if(data){
                        component.find("hiddenActive").set("v.value",true);
                        component.find("hiddenPrimary").set("v.value",true);
                        component.set("v.isEdit",false);
                    }
                    else{
                        if(addressType.includes('Home Address')){
                            component.find("hiddenActive").set("v.value",false);
                            component.find("hiddenPrimary").set("v.value",false);
                            component.set("v.isEdit",true);
                            helper.showToast(component, event, addressType ,$A.get("$Label.c.ContactAddressPrimaryActive"),'error');
                            
                        }
                        else if(addressType.includes('Office Address')){
                            component.find("hiddenActive").set("v.value",false);
                            component.find("hiddenPrimary").set("v.value",false);
                            component.set("v.isEdit",true);
                            helper.showToast(component, event, addressType ,$A.get("$Label.c.ContactAddressPrimaryActiveOffice"),'error');
                            
                        }                
                    }
                    
                }
                else{
                    component.find("hiddenActive").set("v.value",false);
                    component.find("hiddenPrimary").set("v.value",false);
                    component.set("v.isEdit",false);
                    
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    showToast : function(component, event, title ,msg,msgType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            type : msgType,
            duration : 5000,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})