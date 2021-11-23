({
    doInit: function(component, event, helper) {
        //get loading spinner before data gets loaded
        component.set("v.loadingSpinner", true);
        setTimeout(function() {
            component.set("v.loadingSpinner", false);
        }, 2000);
        helper.getServices(component);
    },

    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        component.set("v.isOpen", false);
    },
    //moreinfo of a site
    onMoreInfo: function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var idexParam = selectedItem.dataset.record.split('#');
        var siteindex = idexParam[0];
        var prdindex = idexParam[1];
        var selectedStore = component.get("v.sites.site")[siteindex];
        component.set('v.moreinfo', selectedStore.productList[prdindex]);
        component.set('v.isOpen', true);
    },

    navigateToRollCall: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:GetSites",
            componentAttributes: {
                cidn: component.get("v.cidn"),
            }
        });
        evt.fire();
    },

    checkAllCheckboxes: function(component, event, helper) {
        var serviceDTO = component.get('v.sites.site');
        var checkboxes = component.find("DependentCheckbox");
        var mainchk = component.find("SelectAll");
        var chkflag = false;
        console.log('mainchk' + mainchk.get("v.value"));
        if (mainchk.get("v.value") == true) {
            chkflag = true;
        }
        var k = 0;
        if (checkboxes.length == undefined) {
            checkboxes.set("v.value", chkflag);
        } else {
            for (var i = 0; i < serviceDTO.length; i++) {
                for (var j = 0; j < serviceDTO[i].productList.length; j++) {
                    checkboxes[k].set("v.value", chkflag);
                    k++;
                }
            }
        }
        helper.onCheckBoxSelect(component);
        helper.enableTransitionButton(component);
        helper.enableTransitionButton(component);
    },

    //This function will chk the association of products and select them accordingly.
    onCheckBoxClick: function(component, event, helper) {
        var mainchk = component.find("SelectAll");
        if (mainchk.get("v.value") == true) {
            mainchk.set("v.value", false);
        }
        helper.onCheckBoxSelect(component);
        helper.enableTransitionButton(component);
    },
    //for navigating to get offer UI
    navigateToGetOffer: function(component, event, helper) {
        //getting list of offers from controller class method 
        helper.getOffer(component, event, helper);
    }

})