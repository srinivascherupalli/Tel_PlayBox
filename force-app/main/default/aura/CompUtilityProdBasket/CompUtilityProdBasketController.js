/*
===============================================================================================================================
Component Name : CompUtilityProdBasket
Developer Name : Ravi
COntroller Class : CompUtilityReplicatorManager
===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)
2.        Maq                   23/5/2019     			Entire logic change
===============================================================================================================================
*/
({
    doInit: function(component, event, helper) {
        //console.log('Inside response prdbasket');
        //helper.fireGetServicesEvent(component, event);
        
        //alert(document.getElementById('site0'));
        var checkFirstRun = true;
        setInterval(function() {
            if (checkFirstRun === true) {
                var dom = document.getElementById("site0");
                if (dom != null) {
                    dom.click();
                }
                checkFirstRun = false;
            }
        }, 4000);
    },
    
    displaySites: function(component, event, helper) {
        var siteDTOMap = component.get("v.siteDTOMap");
        var siteDTOList = new Array();
        for (var key in siteDTOMap) {
            siteDTOList.push(siteDTOMap[key]);
        }
        component.set("v.siteCount", siteDTOList.length);
        component.set("v.siteDTOList", siteDTOList);
        //var preSelectedSite = document.querySelectorAll('.theClass');
        //alert(preSelectedSite.length);
    },
    fireGetServicesEvent: function(component, event, helper) {
        if (component.get("v.cmpFlag") == true)
            component.set("v.loadingSpinnerLeft", true);
        // alert('*************>'+JSON.stringify(component.get("v.ProdBasket")));
        
        var preSelectedSite = document.querySelectorAll(".blue-bg");
        if (preSelectedSite.length > 0) {
            try {
                preSelectedSite[0].classList.remove("blue-bg");
                preSelectedSite[0].childNodes[1].classList.add(
                    "display-none");
            } catch (e) {}
        }
        var selectedDiv = event.target.getAttribute("data-id");
        var iconChevron = component.find("iconChevron");
        if (iconChevron) {
            if (iconChevron.length) {
                iconChevron.forEach(function(entry) {
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
        var siteDetail = event.currentTarget.getAttribute("data-id");
        var adborid = siteDetail.split("-");
        //for(var i =0; i<preSelectedSite.length; i++)
        //{
        //   preSelectedSite[i].classList.remove('blue-bg');
        // }
        
        var siteClickedList = component.get("v.siteClickedList");
        
        var i;
        var isAllSiteClicked = false;
        for (i = 0; i < component.get("v.siteDTOList").length; i++) {
            if (component.get("v.siteDTOList")[i].adBorId == adborid[0]) {
                //  alert('*************>'+JSON.stringify(component.get("v.siteDTOList")[i].adBorId));
                if (siteClickedList.includes(adborid[0]) == false) {
                    siteClickedList.push(adborid[0]);
                    component.set("v.siteClickedList", siteClickedList);
                }
            }
        }
        //  alert( component.get("v.siteClickedList").length + "<----->" + component.get("v.siteDTOList").length);
        if (
            component.get("v.siteClickedList").length ==
            component.get("v.siteDTOList").length
        ) {
            isAllSiteClicked = true;
        }
        let clickCountMap = new Map();
        clickCountMap["clickedPanel"] = component.get(
            "v.siteClickedList").length;
        clickCountMap["Total"] = component.get("v.siteDTOList").length;
        component.set("v.allSiteAndMobileClicked", clickCountMap);
        
        //  alert('*************>'+JSON.stringify(component.get("v.siteClickedList"))+'#######>>'+component.get("v.siteClickedList").length);
        event.currentTarget.classList.add("blue-bg");
        event.currentTarget.childNodes[1].classList.remove(
            "display-none");
        //$A.util.addClass(event.currentTarget, 'blue-bg');
        var siteDTOMap = component.get("v.siteDTOMap");
        //     var siteDetail = event.currentTarget.getAttribute("data-id");
        //     var adborid = siteDetail.split("-");
        var siteName = siteDetail.replace(adborid[0] + "-", "");
        //   var sitesMap_V2 = component.get("v.sitesMap_V2");
        var oldConfigId = siteDTOMap[adborid[0]].oldConfigId;
        
        /*-- Call replicator end point on every click on left side of panel ---*/
        console.log('siteDTOMap-->' + JSON.stringify(component.get(
            "v.siteDTOMap")));
        var selectedSiteReplicatorClick;
        //-- This method call replicator to get the response for the given site
        //  alert('*************>'+JSON.stringify(adborid[0]));
        var action = component.get("c.getCustomerServices_New");
        var prodBasSites = component.get("v.siteDTOMap");
        action.setParams({
            finCIDN: component.get("v.cidn"),
            prodBasSites: JSON.stringify(prodBasSites),
            selectedAdborid: adborid[0]
        });
        action.setCallback(this, function(response) {
            var data = "";
            data = response.getReturnValue();
            component.set("v.cmpFlag", true);
            if (data) {
                // -----------------------------------
                var wrapperMapData = new Map();
                wrapperMapData.set(adborid[0], data);
                var wrapperData = new Map();
                wrapperData = component.get("v.allSitesWrapper");
                
                if (wrapperData != null && wrapperData) {
                    //alert('----2nd time----');
                    // -- Response for one the site has already been loaded --
                    var actionResponse = component.get(
                        "c.mergeIndividualSiteResponse");
                    //-- Merging response of two or more site recieved from Replicator --
                    actionResponse.setParams({
                        clickedResponse: data,
                        previousResponses: wrapperData,
                        selectedAdborid: adborid[0],
                        cidnResponse: component.get(
                            "v.cidn")
                    });
                    actionResponse.setCallback(this, function(
                        response) {
                        var mergedData = response.getReturnValue();
                        if (mergedData) {
                            //   alert('*****'+JSON.stringify(mergedData));
                            component.set(
                                "v.allSitesWrapper",
                                mergedData);
                            helper.getServicesMap_V2(
                                component,
                                event,
                                component.get(
                                    "v.allSitesWrapper"
                                ),
                                adborid[0]
                            );
                            component.set(
                                "v.selectedSiteReplicatorData",
                                data);
                            selectedSiteReplicatorClick
                            = data;
                            // Event fire to load data though replicator
                            var sitesMap_V2 = component
                            .get("v.sitesMap_V2");
                            var getSerEvt = $A.get(
                                "e.c:GetServicesEvent"
                            );
                            getSerEvt.setParams({
                                adborid: adborid[
                                    0],
                                siteName: siteName,
                                oldConfigId: oldConfigId,
                                sitesMap_V2: sitesMap_V2,
                                selectedSiteResponse: component
                                .get(
                                    "v.allSitesWrapper"
                                ),
                                callFrom: "fixSheet",
                                allSiteClickedFlag: isAllSiteClicked
                            });
                            getSerEvt.fire();
                            component.set(
                                "v.loadingSpinnerLeft",
                                false);
                        } else {}
                    });
                    $A.enqueueAction(actionResponse);
                } else {
                    // alert('----1nd time----');
                    // -- Loading Response for the first time --
                    component.set("v.allSitesWrapper", data);
                    helper.getServicesMap_V2(component, event,
                                             data, adborid[0]);
                    //    component.set("v.loadingSpinnerLeft", false);
                    component.set(
                        "v.selectedSiteReplicatorData",
                        data);
                    selectedSiteReplicatorClick = data;
                    // component.set('v.sites_new', data);
                    // Event fire to load data though replicator
                    var sitesMap_V2 = component.get(
                        "v.sitesMap_V2");
                    var getSerEvt = $A.get(
                        "e.c:GetServicesEvent");
                    getSerEvt.setParams({
                        adborid: adborid[0],
                        siteName: siteName,
                        oldConfigId: oldConfigId,
                        sitesMap_V2: sitesMap_V2,
                        selectedSiteResponse: component
                        .get("v.allSitesWrapper"),
                        callFrom: "fixSheet",
                        allSiteClickedFlag: isAllSiteClicked
                    });
                    getSerEvt.fire();
                    component.set("v.loadingSpinnerLeft", false);
                }
                //------------------------------------
                
                //    alert('$$$$$$$$$$$--->'+JSON.stringify(wrapperMapData.get(adborid[0])));
                //   alert('$$$$$$$$$$$--->'+JSON.stringify(component.get("v.allSitesWrapper")));
                /*-- Prepraring Map for the selected response --*/
                /*  helper.getServicesMap_V2(component,event, component.get("v.allSitesWrapper"));
                        component.set("v.loadingSpinnerLeft", false);
                        component.set("v.selectedSiteReplicatorData", data);
                        selectedSiteReplicatorClick = data;
                        // component.set('v.sites_new', data);
                        // Event fire to load data though replicator
                        var sitesMap_V2 = component.get("v.sitesMap_V2");
                        var getSerEvt = $A.get("e.c:GetServicesEvent");
                        getSerEvt.setParams({
                            "adborid" : adborid[0],
                            "siteName" : siteName,
                            "oldConfigId" : oldConfigId,
                            "sitesMap_V2": sitesMap_V2,
                            "selectedSiteResponse" : component.get("v.allSitesWrapper"),
                            "callFrom" : "fixSheet"
                        });
                        getSerEvt.fire();   */
            } else {
                component.set("v.loadingSpinnerLeft", false);
            }
        });
        $A.enqueueAction(action);
        /*-- Call replicator end point on every click on left side of panel ---*/
        /*  var getSerEvt = $A.get("e.c:GetServicesEvent");
            getSerEvt.setParams({
                "adborid" : adborid[0],
                "siteName" : siteName,
                "oldConfigId" : oldConfigId,
                "sitesMap_V2": sitesMap_V2,
                "selectedSiteResponse" : component.get("v.selectedSiteReplicatorData"),
                "callFrom" : "fixSheet"
            });
            getSerEvt.fire(); */
        // component.set("v.loadingSpinnerLeft", false);
    },
    
    handleGetSelectedProduct: function(component, event, helper) {
        var selectedProduct = event.getParam("selectedProduct");
        var siteMap2 = new Map();
        siteMap2 = event.getParam("sitesMap_V2");
        //  alert('********************************>'+JSON.stringify(siteMap2));
        component.set("v.sitesMap_V2", siteMap2);
    },
    
    mobileDisplayAction: function(component, event, helper) {
        let params = event.getParam("arguments");
        // alert(params.CIDNString + " ******* " + params.isMobilityProduct);
        if (params.isMobilityProduct == "true") {
            component.set("v.mobileFlag", true);
            let childCmpMobileService = component.find("GetMobileServicePanel");
            childCmpMobileService.getSiteAgnosticService(params.CIDNString, params.basketId);
        }
    }
});