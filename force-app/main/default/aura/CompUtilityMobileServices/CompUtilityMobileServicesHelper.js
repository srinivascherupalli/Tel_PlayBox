({
    doInitHelper: function (component, event, helper) {
        let siteDTOMap = component.get("v.siteDTOMap");
        let siteDTOList = new Array();
        for (let key in siteDTOMap) {
            siteDTOList.push(siteDTOMap[key]);
        }
        var serviceClickMap = new Map();
        serviceClickMap['Mobility'] = 'false';
        serviceClickMap['NgUc'] = 'false';
        component.set("v.isServicesClicked", serviceClickMap);
        //  alert(JSON.stringify('&&&&&&&&&siteDTOList.length-->' + siteDTOList.length));
        if (siteDTOList.length == 0) {
            let checkFirstRun = true;
            setInterval(function () {
                if (checkFirstRun === true) {
                    let dom = document.getElementById(
                        "sitesMobile");
                    if (dom != null) {
                        dom.click();
                    }
                    checkFirstRun = false;
                }
            }, 2000);
        }
    },
    fireGetServicesEvent: function (component, event, helper) {
        //  alert('********inside event>'+JSON.stringify(component.get("v.productFamilyMobile")));
        var preSelectedSite = document.querySelectorAll(".blue-bg");
        console.table("*****" + JSON.stringify(preSelectedSite.length));
        if (preSelectedSite.length > 0) {
            try {
                preSelectedSite[0].classList.remove("blue-bg");
                preSelectedSite[0].childNodes[1].classList.add(
                    "display-none");
            } catch (e) { }
        }
        var selectedDiv = event.target.getAttribute("data-id");
        var iconChevron = component.find("iconChevron");
        // alert(JSON.stringify('&&&&&&&&&-->'+iconChevron.length+"<---&&--->"+selectedDiv))
        if (iconChevron) {
            if (iconChevron.length) {
                iconChevron.forEach(function (entry) {
                    if (entry.get("v.alternativeText") ==
                        selectedDiv) {
                        entry.set("v.iconName",
                            "utility:chevrondown");
                    } else {
                        entry.set("v.iconName",
                            "utility:chevronright");
                    }
                });
            } else {
                if (iconChevron.get("v.alternativeText") == selectedDiv) {
                    iconChevron.set("v.iconName", "utility:chevrondown");
                } else {
                    iconChevron.set("v.iconName",
                        "utility:chevronright");
                }
            }
        }
        event.currentTarget.classList.add("blue-bg");
        let checkedDone = false;
        if (component.get("v.allSiteAndMobileClicked")["Total"] != null && component.get("v.allSiteAndMobileClicked")["Total"] != undefined) {
            if (component.get("v.allSiteAndMobileClicked")["Total"] != component.get("v.allSiteAndMobileClicked")["clickedPanel"])
                checkedDone = false;
            else checkedDone = true;
        } else {
            // -- CWP is not present in the basket, So have to check if mobile or ngUc is present and has been clicked or not
            let serviceClickMapTemp = new Map();
            for (let key in component.get("v.isServicesClicked")) {
                if (key == "Mobility") {
                    serviceClickMapTemp['Mobility'] = 'true';
                }
                else {
                    serviceClickMapTemp[key] = component.get("v.isServicesClicked")[key];
                }
            }
            component.set("v.isServicesClicked", serviceClickMapTemp);
            let serviceClickMap = component.get("v.isServicesClicked");
            let servicePresentMap = component.get("v.isServicesPresent");
            for (let key in servicePresentMap) {
                //    serviceClickMap.push({ value: servicePresentMap[key], key: key });
                if (key == 'NgUc') {
                    if (servicePresentMap[key] == 'false') {
                        checkedDone = true;
                    }
                    else if (servicePresentMap[key] == 'true') {
                     //   alert('********inside event>Out' + JSON.stringify(serviceClickMap));
                        if (serviceClickMap[key] == 'true') {
                     //       alert('********inside event>' + JSON.stringify(serviceClickMap['NgUc']));
                            checkedDone = true;
                        }
                        else {
                            checkedDone = false;
                        }
                    }
                }
            }

        }
        component.set("v.iconName", "utility:chevrondown");
        var getSerEvt = $A.get("e.c:GetServicesEvent");
        var adborid = "";
        var siteName = "";
        var oldConfigId = "";
        var sitesMap_V2 = component.get("v.sitesMap_V2");
        getSerEvt.setParams({
            adborid: adborid,
            siteName: siteName,
            oldConfigId: oldConfigId,
            sitesMap_V2: sitesMap_V2,
            callFrom: "Mobile",
            CIDN_String: component.get("v.CIDN_String"),
            basketId: component.get("v.basketIdString"),
            mobileTransitionDataEvt: component.get("v.mobileTransitionData"),
            selectedMobileRecrodEvt: component.get("v.selectedMobileRecrod"),
            ngUcTransitionDataEvt: component.get("v.ngUcTransitionData"),
            selectedNgUcRecrodEvt: component.get("v.selectedNgUcRecrod"),
            allSiteClickedFlag: checkedDone
        });
        getSerEvt.fire();
    },

    fireGetServicesNGUCEvent: function (component, event, helper) {
        // alert('********inside event>'+JSON.stringify(component.get("v.productFamilyMobile")));

        var preSelectedSite = document.querySelectorAll(".blue-bg");
        console.table("*****" + JSON.stringify(preSelectedSite.length));
        if (preSelectedSite.length > 0) {
            try {
                preSelectedSite[0].classList.remove("blue-bg");
                preSelectedSite[0].childNodes[1].classList.add(
                    "display-none");
            } catch (e) { }
        }
        var selectedDiv = event.target.getAttribute("data-id");
        var iconChevron = component.find("iconChevron");
        // alert(JSON.stringify('&&&&&&&&&-->'+iconChevron.length+"<---&&--->"+selectedDiv))
        if (iconChevron) {
            if (iconChevron.length) {
                iconChevron.forEach(function (entry) {
                    if (entry.get("v.alternativeText") ==
                        selectedDiv) {
                        entry.set("v.iconName",
                            "utility:chevrondown");
                    } else {
                        entry.set("v.iconName",
                            "utility:chevronright");
                    }
                });
            } else {
                if (iconChevron.get("v.alternativeText") == selectedDiv) {
                    iconChevron.set("v.iconName", "utility:chevrondown");
                } else {
                    iconChevron.set("v.iconName",
                        "utility:chevronright");
                }
            }
        }
        event.currentTarget.classList.add("blue-bg");
        let checkedDone = false;
        if (component.get("v.allSiteAndMobileClicked")["Total"] != null && component.get("v.allSiteAndMobileClicked")["Total"] != undefined) {
            if (component.get("v.allSiteAndMobileClicked")["Total"] != component.get("v.allSiteAndMobileClicked")["clickedPanel"])
                checkedDone = false;
            else checkedDone = true;
        } else {
            //checkedDone = true;
            // -- CWP is not present in the basket, So have to check if mobile or ngUc is present and has been clicked or not
            let serviceClickMapTemp = new Map();
            for (let key in component.get("v.isServicesClicked")) {
                if (key == "NgUc") {
                    serviceClickMapTemp['NgUc'] = 'true';
                }
                else {
                    serviceClickMapTemp[key] = component.get("v.isServicesClicked")[key];
                }
            }
            component.set("v.isServicesClicked", serviceClickMapTemp);
            let serviceClickMap = component.get("v.isServicesClicked");
            let servicePresentMap = component.get("v.isServicesPresent");
            for (let key in servicePresentMap) {
                //    serviceClickMap.push({ value: servicePresentMap[key], key: key });
                if (key == 'Mobility') {
                    if (servicePresentMap[key] == 'false') {
                        checkedDone = true;
                    }
                    else if (servicePresentMap[key] == 'true') {
                      //  alert('********inside event>Out' + JSON.stringify(serviceClickMap));
                        if (serviceClickMap[key] == 'true') {
                         //   alert('********inside event>' + JSON.stringify(serviceClickMap['Mobility']));
                            checkedDone = true;
                        }
                        else {
                            checkedDone = false;
                        }
                    }
                }
            }

        }
        component.set("v.iconName", "utility:chevrondown");

        // -- Firing event for ngUC : start --
        var getSerEvt = $A.get("e.c:GetServicesEvent");
        var adborid = "";
        var siteName = "";
        var oldConfigId = "";
        var sitesMap_V2 = component.get("v.sitesMap_V2");
        getSerEvt.setParams({
            adborid: adborid,
            siteName: siteName,
            oldConfigId: oldConfigId,
            sitesMap_V2: sitesMap_V2,
            callFrom: "ngUC",
            CIDN_String: component.get("v.CIDN_String"),
            basketId: component.get("v.basketIdString"),
            mobileTransitionDataEvt: component.get("v.mobileTransitionData"),
            selectedMobileRecrodEvt: component.get("v.selectedMobileRecrod"),
            ngUcTransitionDataEvt: component.get("v.ngUcTransitionData"),
            selectedNgUcRecrodEvt: component.get("v.selectedNgUcRecrod"),
            allSiteClickedFlag: checkedDone
        });
        getSerEvt.fire();
        // -- Firing event for ngUC : end --

    },

    onClickMobile: function (component, event, helper) { },
    mobileDisplayAction: function (component, event, helper) {
        let params = event.getParam("arguments");
        component.set("v.CIDN_String", params.CIDNString);
        component.set("v.basketIdString", params.basketId);
        //  alert('********CompUtilityMobileServices>'+JSON.stringify(params.CIDNString));
        component.set("v.mobileFlag", true);
        if (params.CIDNString != null) {
            component.set("v.mobileFlag", true);
        }
        this.typeOfServicePresent(component, event, helper);
    },
    mobileSelectionCompleted: function (component, event, helper) {
        // alert('event ---> '+event.getParam("allSiteClickedFlag"));
        let params = event.getParams();
        // alert("Im In subcatch------>"+JSON.stringify(params.mobileTransitionData));
        component.set("v.selectedMobileRecrod", params.SelectedMobileRecrod);
        component.set("v.mobileTransitionData", params.mobileTransitionData);
        component.set("v.selectedNgUcRecrod", params.SelectedNgUCRecrod);
        component.set("v.ngUcTransitionData", params.ngUcTransitionData);
        // alert("Im In sub------>"+JSON.stringify(params.SelectedNgUCRecrod) +'*****> '+JSON.stringify(params.mobileTransitionData));
    },
    typeOfServicePresent: function (component, event, helper) {
        let action = component.get("c.servicesPresentInTransition");
        action.setParams({
            basketId: component.get("v.basketIdString")
        });
        action.setCallback(this, function (response) {
            let data = response.getReturnValue();
            if (response.getState() == "SUCCESS" && data != null) {
                 console.log('*******servicesPresent123' + JSON.stringify(data));
                component.set("v.isServicesPresent", data);
                /*    
                    var serviceClickMap = [];
                    for (var key in data) {
                        serviceClickMap.push({ value: data[key], key: key });
                    }
                    alert("Im In subserviceClickMap------>" + JSON.stringify(serviceClickMap));
                */
            }
        });
        $A.enqueueAction(action);
    }
});