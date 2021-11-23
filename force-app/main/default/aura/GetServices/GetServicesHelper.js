({
    getServices: function(component) {
        console.log("Inside the helpwe");
        var action = component.get('c.getCustomerServicesAtSite');
        var siteNameArray = component.get('v.siteNameArray');
        var adborid = component.get('v.adborid');
        var cidn = component.get('v.cidn');
        action.setParams({
            "finCIDN": cidn,
            "adbor_Id": adborid,
            "siteNameArray": siteNameArray
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set('v.sites', data);
        });
        $A.enqueueAction(action);
    },
    enableTransitionButton: function(component) {
        var checkboxes = component.find("DependentCheckbox");
        var mainchk = component.find("SelectAll");
        var chkflag = false;
        if (checkboxes.length == undefined) {
            if (checkboxes.get("v.value") == true) {
                chkflag = true;
            }
        } else {
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i].get("v.value") == true) {
                    chkflag = true;
                }
            }
        }
        if (chkflag == false) {
            mainchk.set("v.value", chkflag);
        }
        component.find("transitionbutton").set("v.disabled", !chkflag);
    },

    getOffer: function(component, event, helper, offers) {
        var sites = component.get("v.selectedSite");
        console.log('All Products' + JSON.stringify(sites));
        var action = component.get('c.getEligibleOffers');
        action.setParams({
            "legacyService": JSON.stringify(sites)
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            var offers = data;
            console.log('Offers' + JSON.stringify(offers));
            if (response.getState()) {
                this.getBasket(component, event, helper, offers);
            }
        });
        $A.enqueueAction(action);
    },

    getBasket: function(component, event, helper, offers) {
        var offer_len;
        if (offers == null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "message": "No matching offer identified"
            });
            toastEvent.fire();
        } else {
            offer_len = offers.length;
        }
        var sites = component.get("v.selectedSite");
        var siteName = component.get("v.siteName");
        if (offer_len == 1) {
            //if only 1 offer then redirect to basket page with that offer
            component.set("v.selectedOffer", offers);
            var action = component.get('c.redirectToBasket');
            action.setParams({
                "legacyProd": JSON.stringify(sites),
                "selectedOffer": JSON.stringify(offers),
                "opportunityID": component.get('v.oppId')
            });
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                // this data will be string url to which we have to navigate
                if (data != null && response.getState()) {
                    var urlToBasket = window.location.href;
                    var occ = urlToBasket.indexOf('#');
                    var actualURL = urlToBasket.substring(0, occ) + '#/sObject' + data;
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": actualURL
                    });
                    urlEvent.fire();
                } else {
                    this.showToast(component, 'Failure', "Please contact Administrator for help!");
                }
            });
            $A.enqueueAction(action);
        } else if (offer_len!=undefined && offer_len > 1) {
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:GetOffers",
                componentAttributes: {
                    offers: offers,
                    sites: sites,
                    siteName: siteName,
                    oppId: component.get("v.oppId")
                }
            });
            evt.fire();
        } else if (offer_len == 0) {
            this.showToast(component, 'Failure', "No matching offer identified");
        }
    },

    onCheckBoxSelect: function(component) {
        var actionForObj = component.get('c.getReplicatorGetServiceDataObject');
        actionForObj.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set('v.selectedSite', data);
            if (response.getState()) {
                this.selectedDTO(component);
            }
        });
        $A.enqueueAction(actionForObj);
    },
    selectedDTO: function(component) {
        var checkboxes = component.find("DependentCheckbox");
        var selectedDTO = component.get('v.selectedSite');
        var objDTO = component.get('v.sites');
        selectedDTO.CIDN = objDTO.CIDN;
        selectedDTO.Correlation_Id = objDTO.Correlation_Id;
        var selection=[];
        var k=0;
        if (checkboxes.length == undefined) {
            if (checkboxes.get("v.value") == true) {
                selectedDTO.site.push(objDTO.site[0]);
                component.set('v.selectedSite', selectedDTO);
            }
        } else {
            for (var j = 0; j < objDTO.site.length; j++) {
                for (var i = 0; i < objDTO.site[j].productList.length; i++) {
                    if (checkboxes[k].get("v.value") == true) { 
                        selection.push('true');                                                
                    }
                    else{
                        selection.push('false');                        
                    }
                    k++;
                }
            }
        var action = component.get('c.getSelectedSite');
        action.setParams({
            "checkboxes": JSON.stringify(selection),
            "legacyService": JSON.stringify(objDTO)
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();            
            if(response.getState()=='SUCCESS'){
               console.log('data:'+JSON.stringify(data));
               component.set('v.selectedSite', data);
            }
        });
        $A.enqueueAction(action);
        }
    },

    showToast: function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration: 2500,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }

})