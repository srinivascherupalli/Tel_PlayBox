/*
Name : PpvComponent Helper
Description : Lightning Helper functions for Post verification of numbers 
Author: Kalashree Borgaonkar
Story: EDGE-90327
*/
({
    //EDGE-90327, Initialise component with values
    doInit: function(component, event) {
        var basketId = component.get("v.basket_Id");
        var action = component.get("c.getDetails");
        action.setParams({
            basketid: basketId
        });
        // set call back
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state:", state);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                component.set("v.detailWrapper", resp);
            } else {
                console.log("error");
            }
        });
        // enqueue the server side action
        $A.enqueueAction(action);
    },
    
    //EDGE-90327, Make callout to PPV tool
    handleSave: function(component, event) {},
    //EDGE-90327, get authorised contacts for search input
    getContactsForInput: function(component, event) {
        console.log("getContactsForInput");
        var accountid = component.get("v.detailWrapper.accountid");
        var oppId = component.get("v.detailWrapper.oppId");
        var getInputString = component.get("v.searchContact");
        if (getInputString != null) {
            if (getInputString.length > 0 || getInputString == "") {
                var forOpen = component.find("searchRes3");
                $A.util.addClass(forOpen, "slds-is-open");
                $A.util.removeClass(forOpen, "slds-is-close");
                var forclose2 = component.find("lookupContact");
                $A.util.addClass(forclose2, "slds-is-open");
                $A.util.removeClass(forclose2, "slds-hide");
                
                this.searchContact(component, event, getInputString, accountid, oppId);
                //helper.searchContact(component,event,getInputString);
            } else {
                var forclose = component.find("searchRes3");
                $A.util.addClass(forclose, "slds-is-close");
                $A.util.removeClass(forclose, "slds-is-open");
                var forclose2 = component.find("lookupContact");
                $A.util.addClass(forclose2, "slds-is-close");
                $A.util.removeClass(forclose2, "slds-is-open");
            }
        }
    },
    searchContact: function(component, event, getInputString, accountid, oppid) {
        var action = component.get("c.getContactsForSearch");
        action.setParams({
            accountId: accountid,
            oppId: oppid,
            searchText: getInputString
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                component.set("v.listOfContactRecords", data);
            }
        });
        $A.enqueueAction(action);
    },
    searchPort: function(component, event, getInputString, accountid, oppid) {
        console.log("in searchPort");
        var action = component.get("c.getPortInMsisdns");
        action.setParams({
            accountId: accountid,
            oppId: oppid,
            searchText: getInputString
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log("data: ", data);
                component.set("v.listOfPortNumbers", data);
            }
        });
        $A.enqueueAction(action);
    },
    //EDGE-90327, get authorised contacts for search input
    getPortNumForInput: function(component, event) {
        console.log("getPortNumForInput");
        var accountid = component.get("v.detailWrapper.accountid");
        var oppId = component.get("v.detailWrapper.oppId");
        var getInputString = component.get("v.searchPortNum");
        console.log(getInputString);
        if (getInputString != null) {
            if (getInputString.length > 0 || getInputString == "") {
                var forOpen = component.find("searchRes4");
                $A.util.addClass(forOpen, "slds-is-open");
                $A.util.removeClass(forOpen, "slds-is-close");
                var forclose2 = component.find("lookupPort");
                $A.util.addClass(forclose2, "slds-is-open");
                $A.util.removeClass(forclose2, "slds-hide");
                this.searchPort(component, event, getInputString, accountid, oppId);
                
            } else {
                var forclose = component.find("searchRes3");
                $A.util.addClass(forclose, "slds-is-close");
                $A.util.removeClass(forclose, "slds-is-open");
                var forclose2 = component.find("lookupContact");
                $A.util.addClass(forclose2, "slds-is-close");
                $A.util.removeClass(forclose2, "slds-is-open");
            }
        }
    },
    //EDGE-90327 : Call the lightning contact event
    handleContactEvent: function(component, event) {
        var eventParam = event.getParam("contactByEventDynamic");
        var contactName = eventParam.Contact.Name;
        console.log("contactName", contactName);
        component.set("v.searchContact", contactName);
        component.set("v.listOfContactRecords", null);
        var forclose = component.find("lookupContact");
        $A.util.addClass(forclose, "slds-is-close");
        $A.util.removeClass(forclose, "slds-is-open");
        $A.util.addClass(forclose, "slds-hide");
        // this.handleOnblur(component, event);
    },
    handlePortEvent: function(component, event) {
        var eventParam = event.getParam("portByEvent");
        var portMsisdn = eventParam.Service_Number__c;
        console.log("portMsisdn", portMsisdn);
        component.set("v.searchPortNum", portMsisdn);
        component.set("v.listOfPortNumbers", null);
        var forclose = component.find("lookupPort");
        $A.util.addClass(forclose, "slds-is-close");
        $A.util.removeClass(forclose, "slds-is-open");
        $A.util.addClass(forclose, "slds-hide");
        // this.handleOnblur(component, event);
    },
    
    //EDGE-90327, Save the record
    handleSave: function(component, event) {
        var portNum = component.get("v.searchPortNum");
        var contact = component.get("v.searchContact");
        var accountid = component.get("v.detailWrapper.accountid");
        var externalId = component.get("v.detailWrapper.activeCAF");
        component.set("v.loadingSpinner", true);
        var action = component.get("c.ppvCallout");
        action.setParams({
            accountId: accountid,
            portNumber: portNum,
            externalId: externalId,
            contactName: contact
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.log("data: ", data);
                if (data != null) {
                    if (data.code != "202") {
                        this.showCustomToast(component, data.message, "Error", "error");
                    } else {
                        this.showCustomToast(component, data.message, "Success", "success");
                    }
                } else {
                    this.showCustomToast(component, "Error", "Error", "error");
                }
            } else {
                this.showCustomToast(component, response.getError(), "Error", "error");
            }
            component.set("v.loadingSpinner", false);
            var cmpTarget = component.find("maincontainer");
            // $A.util.removeClass(cmpTarget, 'slds-show');
            $A.util.addClass(cmpTarget, "slds-hide");
        });
        $A.enqueueAction(action);
    },
    //EDGE-90327: Show the message box.
    showCustomToast: function(cmp, message, title, type) {
        $A.createComponent(
            "c:customToast",
            {
                type: type,
                message: message,
                title: title,
                isOKActive: "false"
            },
            function(customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("parentcontainer");
                    body.set("v.body", customComp);
                }
            }
        );
    },
    //EDGE-90327, Initialise component with values
    handleOnblur: function(component, event) {
        var portNum = component.get("v.searchPortNum");
        var contact = component.get("v.searchContact");
        if (
            portNum != null &&
            portNum != "" &&
            (contact != null && contact != "")
        ) {
            component.set("v.isSaveDisabled", false);
        } else {
            component.set("v.isSaveDisabled", true);
        }
    },
    //EDGE-89299,Method to handle event
    handleEvent: function(component, event) {
        var name = event.getParam("basketID"); // getting the value of event attribute
        var toggleMobile = component.find("maincontainer");
        $A.util.removeClass(toggleMobile, "slds-hide");
        $A.util.addClass(toggleMobile, "slds-show");
         //EDGE-117585 Kalashree Borgaonkar. Contact to be sent to PPV Comp--> 
        var contactName = event.getParam("defaultContact");
        component.set("v.searchContact",contactName);
    },
    //EDGE-90327, close the pop up box.
    handleClose: function(component, event) {
        var toggleMobile = component.find("maincontainer");
        $A.util.addClass(toggleMobile, "slds-hide");
        var compEvent = component.getEvent("sampleComponentEvent");
        compEvent.fire();
    },
    // call by child component by a Lightning event handler
    handleSampleEvent: function(component, event) {
        alert("in parent");
        var cmpTarget = component.find("maincontainer");
        $A.util.removeClass(cmpTarget, "slds-show");
        $A.util.addClass(cmpTarget, "slds-hide");
    },
    handlePpvEvent: function(component, event) {
        this.doInit(component, event);
    }
});