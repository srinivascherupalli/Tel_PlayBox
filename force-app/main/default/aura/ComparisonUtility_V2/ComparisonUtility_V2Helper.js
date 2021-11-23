/*
===============================================================================================================================
Component Name : ComparisonUtility_v2
Developer Name : Ravi
COntroller Class : CompUtilityReplicatorManager
===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
({
    SUCCESS: "success",
    ERROR: "error",
    
    getServices_V2: function (component) {
        var action = component.get("c.getCustomerServices_New");
        var cidn = component.get("v.ProdBasket.csbb__Account__r.CIDN__c");
        var prodBasSites = component.get("v.siteDTOMap");
        var adb_Id = "";
        for (var key in prodBasSites) {
            if (prodBasSites.hasOwnProperty(key)) {
                adb_Id = key;
                break;
            }
        }
        
        //   alert('*************>'+JSON.stringify(adb_Id) +'<@@@@@@>'+JSON.stringify(prodBasSites));
        this.getSiteAgnosticServices(component);
        var basketId = component.get("v.basketId");
        action.setParams({
            finCIDN: cidn,
            prodBasSites: JSON.stringify(prodBasSites),
            selectedAdborid: adb_Id
        });
        action.setCallback(this, function (response) {
            var data = response.getReturnValue();
            //    alert('*************>'+JSON.stringify(adb_Id) +'<@@@@@@>'+JSON.stringify(data));
            
            if (data) {
                component.set("v.sites_new", data);
                this.getServicesMap_V2(component);
            } else {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    getServicesMap_V2: function (component) {
        var emptyMap = new Map();
        var action = component.get("c.getCustomerServicesMap_New");
        var serviceDTO = component.get("v.sites_new");
        action.setParams({
            serviceDTO_V2: JSON.stringify(serviceDTO),
            sitesMap_v2Custom: emptyMap
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var mapData = response.getReturnValue();
            component.set("v.sitesMap_V2", mapData);
            this.getISDNBRAProduct_V2(component);
        });
        $A.enqueueAction(action);
        //this.reviewConfirmDisabledHelper(component,event,helper);
    },
    getISDNBRAProduct_V2: function (component) {
        var action = component.get("c.getISDNBRAProduct_V2");
        var serviceDTO = component.get("v.sites_new");
        var basketId = component.get("v.basketId");
        action.setParams({
            basketId: basketId,
            serviceDTO_V2: JSON.stringify(serviceDTO)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var mapData = response.getReturnValue();
            component.set("v.mapProdIds", mapData);
            if (
                component.get("v.ProdBasket.csordtelcoa__Basket_Stage__c") ==
                "Commercial Configuration"
            ) {
                var selectedProdList = component.get("v.mapProdIds")["ISDNBRA"];
                selectedProdList.push(component.get("v.mapProdIds")["PSTN"]);
                selectedProdList.push(component.get("v.mapProdIds")["ISDN2"]);
                selectedProdList.push(component.get("v.mapProdIds")["ISND2DID"]);
                component.set(
                    "V.selectedProd",
                    component.get("v.mapProdIds")["ISDNBRA"]
                ); //To add PSTN and ISDNDID DID2 Products
                //component.set("V.selectedProd",selectedProdList);
            }
            //component.set("V.readOnlyProd",component.get("v.mapProdIds")['NonISDNBRA']);
            //component.set("V.readOnlySelectedProd",component.get("v.mapProdIds")['TransISDNBRAProd']);
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
    },
    getBasket: function (component, event, helper) {
        var action = component.get("c.getBasket");
        var basketId = component.get("v.basketId");
        action.setParams({
            basketId: basketId
        });
        action.setCallback(this, function (response) {
            var data = response.getReturnValue();
            console.log("Insdie get basket data");
            //    alert('********getBasket>'+JSON.stringify(data));
            component.set("v.ProdBasket", data);
            //this.getServices(component);
            if (component.get("v.ProdBasket").Transition_basket_stage__c == null) {
                this.updateProdBasketToInitial(component, event, helper);
            }
            this.getServices_V2(component);
            
            //edge -90448 start
            var productBasket = component.get("v.ProdBasket");
            console.log("basket ****" + productBasket);
            console.log('****' +productBasket.Transition_basket_stage__c);
            if (productBasket != null) {
                if (
                    productBasket.Transition_basket_stage__c ==
                    "Check Eligibility Triggered"
                ) {
                    component.set("v.loadingFixedSpinner", true);
                } else if (
                    productBasket.Transition_basket_stage__c == "Modify Selected"
                ) {
                    component.set("v.hideCheckboxColumn", false);
                    component.set("v.loadingFixedSpinner", fasle);
                } else if (
                    productBasket.Transition_basket_stage__c =="Check Eligibility Completed"
                ) {
                    component.set("v.hideCheckboxColumn", true);
                    component.set("v.loadingFixedSpinner", false);
                    this.reviewConfirmedDisabledCalculateHelper(component, event, helper);
                }
            }
            
            //component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
        //component.set("v.loadingSpinner", false);
        //this.reviewConfirmDisabledHelper(component,event,helper);
        //component.set('v.columns', helper.getColumnDefinitions());
        //this.buttonvaluemapHelpetr(component,event,helper);
        //this.updateProdBasketToInitial(component,event,helper);
    },
    selectedDTO_V2: function (component, event, helper, sendCallout) {
        var serviceDTO = component.get("v.sites_new");
        var siteMap2 = component.get("v.sitesMap_V2");
        var basketID = component.get("v.basketId");
        var action = component.get("c.getSelectedSite_V2");
        console.log('mobileTransitionData@@1',JSON.stringify(component.get("v.mobileTransitionData")));
        action.setParams({
            serviceDTO_V2: JSON.stringify(serviceDTO),
            basketId: basketID,
            siteMap2: JSON.stringify(siteMap2),
            SendCallout: sendCallout
        });
        action.setCallback(this, function (response) {
            var data = response.getReturnValue();
            if (response.getState() == "SUCCESS") {
                console.log("Test Data:::::" +JSON.stringify(data));
                component.set("v.selectedSite", data);
            }
            component.set("v.loadingSpinner", false);
        });
        console.log('mobileTransitionData@@2',JSON.stringify(component.get("v.mobileTransitionData")));
        $A.enqueueAction(action);
		//Added for EDGE-213602 Fix
		
		var clickedBtn = event.getSource().getLocalId();
        //DIGI-18348:- Added clickedBtn =="button" to restrict mulitple Save Selection calls on button click by Abhishek(Osaka)
        if(component.get("v.isMobilityProduct") == "true" && !(clickedBtn =="reviewandconfirm" || clickedBtn =="review" || clickedBtn =="button")) {
            console.log("clickedBtn is:", clickedBtn);
        	this.saveMobileTransition(component, event, helper);
        }
        
        
        //End for EDGE-213602 Fix

        this.reviewConfirmedDisabledCalculateHelper(component, event, helper);
        ///this.buttonvaluemapHelpetr(component,event,handler);
    },
    navigateToRollCall: function (component, event, helper) {
        var urlToBasket = window.location.href;
        var occ = urlToBasket.indexOf("#");
        var actualURL =
            urlToBasket.substring(0, occ) +
            "#/sObject/" +
            component.get("v.basketId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: actualURL
        });
        urlEvent.fire();
    },
    getServiceCount: function (component) {
        var action = component.get("c.getServiceCount");
        action.setCallback(this, function (response) {
            var data = response.getReturnValue();
            if (response.getState() == "SUCCESS") {
                component.set("V.serviceCount", data);
                //alert(data);
            }
        });
        $A.enqueueAction(action);
    },
    
    showCustomToast: function (cmp, message, title, type) {
        $A.createComponent(
            "c:customToast",
            {
                type: type,
                message: message,
                title: title
            },
            function (customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");
                    body.set("v.body", customComp);
                } else if (status === "INCOMPLETE") {
                    console.log("no resonse");
                } else if (status === "ERROR") {
                    console.log("error : " + error);
                }
            }
        );
    },
    //helper method to fetch data for review and confirm table
    openReviewConfirm: function (component, event) {
        var siteMap_v2 = component.get("v.sitesMap_V2");
        var action = component.get("c.getReviewConfirmDataNew");
      //  console.log("Im In  before call------>" + JSON.stringify(component.get("v.siteDTOMap")));
      //  console.log("Im In  before call another------>" + JSON.stringify(siteMap_v2));
        //var sitesMap_v2 =component.get("v.sitesMap_v2");
        action.setParams({
            sitesMap_v2: siteMap_v2,
            siteDTOMap: component.get("v.siteDTOMap")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var tableData = response.getReturnValue();
           // console.log("Im In  CWP------>" + JSON.stringify(tableData));
            var listReviewConfirmCWP = [];
            for (var key in tableData) {
                  listReviewConfirmCWP.push(tableData[key]); 
            }
            component.set("v.listReviewConfirmCWP", listReviewConfirmCWP);
          //  console.log("Im In  CWP lIst------>" + JSON.stringify(listReviewConfirmCWP)+"****"+"Im In  CWP lIst------>" + listReviewConfirmCWP.length);
            
            var sendCallout = false;
            //this.selectedDTO_V2(component, event, helper,sendCallout);
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
        // make changes here
        let actionTable = component.get("c.getMobileServicesTablewrapper");
        actionTable.setParams({
            transitionMoblileData: component.get("v.mobileTransitionData"),
            basketId: component.get("v.basketId")
        });
        actionTable.setCallback(this, function (response) {
            let tableData = response.getReturnValue();
            
            if (tableData) {
                component.set("v.mobilityColumns", [
                    //EDGE-139071 Start
                    /*{
                        label: "PRODUCT",
                        fieldName: "Product_Type",
                        type: "text",
                        cellAttributes: { class: { fieldName: "CSSClass" } }
                    },*/
                    //Start of EDGE-195976::Pradeep Mudenur:Added CIDN,ABN and BAN
                    { label: "CIDN", fieldName: "source_CIDN", type: "text" },
                    { label: "ABN", fieldName: "ABN", type: "text" },
                    //END of EDGE-195976
                    { label: "Service ID", fieldName: "Product_Number", type: "text" },
                    { label: "Current Plan", fieldName: "plan_name", type: "text" },
                    { label: "BAN", fieldName: "BAN", type: "text" },
                    {
                        label: "Plan Type",
                        fieldName: "Plan_Type",
                        type: "text",
                        cellAttributes: { class: { fieldName: "CSSClass" } }
                    },
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team Start
                   // { label: "Contract Term", fieldName: "contract_term", type: "text" },
                    {label: "Remaining Term", fieldName: "contract_remaining_term", type: "text"},
                    //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team End
                    { label: "Partner Dealer Code", fieldName: "Dealer_Code", type: "text" },
                    
                    //Start of EDGE-207157 by Abhishek(Osaka)
                    { label: "Nickname", fieldName: "user_name", type: "text" }
                    //End of EDGE-207157 by Abhishek(Osaka)
                    /*{
                        label: "ELIGIBILITY STATUS",
                        fieldName: "eligibilityStatus",
                        type: "text"
                    },
                    { label: "REASON", fieldName: "eligibilityReason", type: "text" }*/
                    //EDGE-139071 End
                ]);
                component.set("v.mobileResponseTable", tableData);
                //EDGE-164031 changes by Rahul to dynamically calculate the count// 
                this.getSelectedCount(component);

                //Start of DIGI-1741 by Abhishek(Osaka) to hit validation for Plan Configuration Mode on confirm button
                var planConfigMode;
                tableData.forEach(function (obj){
                    planConfigMode = obj.planConfigMode;
                });
                component.set("v.planConfigMode",planConfigMode);
                //End of DIGI-1741 by Abhishek(Osaka)
               
            }
        });
        $A.enqueueAction(actionTable);
       // alert("Im In  nguc------>" + JSON.stringify(component.get("v.ngUcTransitionData")));
        // Changes made for NgUc - Review and Confirm
        component.set("v.ngUcColumns", [
            {
                label: "PRODUCT",
                fieldName: "Product_Type",
                type: "text",
                cellAttributes: { class: { fieldName: "CSSClass" } }
            },
            { label: "FNN", fieldName: "FNN_Number", type: "text" },
            { label: "Type", fieldName: "Association_Type", type: "text" },
            { label: "CONTRACT TERM", fieldName: "contract_term", type: "text" },
            {
                label: "ELIGIBILITY STATUS",
                fieldName: "eligibilityStatus",
                type: "text"
            },
            { label: "REASON", fieldName: "eligibilityReason", type: "text" }
        ]);
        let actionTableNguc = component.get("c.getNgUcServicesTablewrapper");
        actionTableNguc.setParams({
            transitionMoblileData: component.get("v.ngUcTransitionData"),
            basketId: component.get("v.basketId")
        });
        actionTableNguc.setCallback(this, function (response) {
            let tableData = response.getReturnValue();
           // console.log("Im In  nguc------>" + JSON.stringify(tableData));
            if (tableData) {
                component.set("v.ngUCResponseTable", tableData);
                //EDGE-164031 changes by Rahul to dynamically calculate the count// 
                this.getSelectedCountNguc(component);
            }
        });
        $A.enqueueAction(actionTableNguc);
        
    },
    //method to handle
    processTransition: function (component, event, helper) {
        var callSelectedProduct = $A.get("e.c:CallGetSelectedProduct");
        callSelectedProduct.fire();
    },
    //method to define review and confirm table columns
    getColumnDefinitions: function () {
        //var columnsWidths = this.getColumnWidths();
        var columns = [
            {
                label: "Offer",
                fieldName: "offer",
                type: "text"
            },
            {
                label: "Legacy Technology",
                fieldName: "legacyTechnology",
                type: "text"
            },
            {
                label: "Order Type",
                fieldName: "orderType",
                type: "text"
            },
            {
                label: "Site Name",
                fieldName: "siteName",
                type: "text"
            },
            {
                label: "Locality",
                fieldName: "locality",
                type: "text"
            },
            {
                label: "State",
                fieldName: "state",
                type: "text"
            },
            {
                label: "FNN",
                fieldName: "fNN",
                type: "text"
            }
        ];
        return columns;
    },
    //method to set iseligibility flag on product basket
    setIsEligibilityTriggered: function (component, event, helper) {
        var action1 = component.get("c.setIsEligibilityTriggeredUpdate");
        action1.setParams({
            basketId: component.get("v.basketId")
        });
        action1.setCallback(this, function (response) {
            var data = response.getReturnValue();
            if (response.getState() == "SUCCESS") {
                component.set("v.loadingFixedSpinner", true);
            }
        });
        $A.enqueueAction(action1);
    },
    buttonvaluemapHelpetr: function (component, event, handler) {
        var action2 = component.get("c.HandleButtonHideShow");
        var buttonmap = new Map();
        action2.setParams({ basketId: component.get("v.basketId") });
        action2.setCallback(this, function (response) {
            buttonmap = response.getReturnValue();
            if (response.getState() == "SUCCESS" && buttonmap != null) {
                component.set("v.ProdbuttonMap", buttonmap);
                component.set(
                    "v.displayTransBtn",
                    component.get("v.ProdbuttonMap")["displayTransBtn"]
                );
                component.set(
                    "v.checkEligibilityInprogress",
                    component.get("v.ProdbuttonMap")["checkEligibilityInprogress"]
                );
                component.set(
                    "v.checkEligibilityComplete",
                    component.get("v.ProdbuttonMap")["checkEligibilityComplete"]
                );
            }
        });
        $A.enqueueAction(action2);
    },
    //added for edge -90448
    updateProdBasketToInitial: function (component, event, handler) {
        //alert('Inside updateProdBasketToInitial');
        component.set("v.loadingSpinner", true);
        var action2 = component.get("c.updatetransitionBasketStagetoInitial");
        action2.setParams({
            basketId: component.get("v.basketId")
        });
        action2.setCallback(this, function (response) {
            var basket = response.getReturnValue();
            if (response.getState() == "SUCCESS" && basket != null) {
                component.set("v.ProdBasket", basket);
            }
            //alert(basket);
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action2);
    },
    //added for edge -90448
    updateProdBasketToCheckEligibility: function (component, event, handler) {
        component.set("v.loadingSpinner", true);
        var action2 = component.get(
            "c.updatetransitionBasketStagetoCheckEligibility"
        );
        action2.setParams({
            basketId: component.get("v.basketId")
        });
        action2.setCallback(this, function (response) {
            var basket = response.getReturnValue();
            console.log(basket);
            if (response.getState() == "SUCCESS" && basket != null) {
                component.set("v.ProdBasket", basket);
            }
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action2);
    },
    //added for edge -90448
    updateProdBasketToModifySelection: function (component, event, handler) {
        //component.set("v.loadingSpinner", true);
        var action2 = component.get(
            "c.updatetransitionBasketStagetoModifySelection"
        );
        action2.setParams({
            basketId: component.get("v.basketId")
        });
        action2.setCallback(this, function (response) {
            var basket = response.getReturnValue();
            if (response.getState() == "SUCCESS" && basket != null) {
                component.set("v.ProdBasket", basket);
            }
            component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action2);
    },
    //to calculculate review button disabled or enabled //added for edge -90448
    reviewConfirmedDisabledCalculateHelper: function (component, event, handler) {
        console.log("Inside review calculates",component.get("v.checkReviewConfirm"));
               
      component.set("v.checkEligibilityInprogress",false);
        component.set("v.checkEligibilityComplete", true);
        component.get("v.checkEligibilityComplete");
        component.set("v.displayTransBtn", false); 
     component.set("v.MROScreenenabled", false);
        component.set("v.ifInTranstion", true);
      
        var sitesMap_v2 = component.get("v.sitesMap_v2");
        var action = component.get("c.reviewConfirmedDisabledCalculate");
        console.log(action);
        action.setParams({
            sitesMap_v2: sitesMap_v2,
            basketID: component.get("v.basketId")
        });
        action.setCallback(this, function (response) {
            var reviewConfirmedDisabled = response.getReturnValue();
            console.log(">>>>>>" + response.getState());
            if (response.getState() == "SUCCESS") {
                if(reviewConfirmedDisabled==true){
                    component.set("v.reviewConfirmdisabled",true);
                    
                }
                else{
                    component.set("v.reviewConfirmdisabled",false);
                }
          component.set("v.reviewConfirmdisabled", reviewConfirmedDisabled);
      }
        component.set("v.loadingSpinner", false);
    });
      $A.enqueueAction(action);
  },
    getSiteAgnosticServices: function (component) {
        //----------- Mobile related Code------
        let childCmpMobileService = component.find("GetSiteComp");
        if(childCmpMobileService!=null || childCmpMobileService !=undefined){
            childCmpMobileService.getSiteAgnosticService(
            component.get("v.ProdBasket.csbb__Account__r.CIDN__c"),
            component.get("v.basketId"),
          //  component.get("v.isMobilityProduct")
           "true" // changes done for ngUc
        );
        }
        
        //----------- Mobile related Code------
    },
    saveMobileTransition: function (component, event, helper) {
        //----------- Mobile Code------
        component.set("v.loadingSpinner", true);
        console.log("Im In MobilePage------>" + JSON.stringify(component.get("v.selectedMobileRecrod")) + '*****> ' + JSON.stringify(component.get("v.mobileTransitionData")));
		var transitionList = component.get("v.mobileTransitionData");
		var selectedMobile = component.get("v.selectedMobileRecrod");

       /* if(transitionList.productList[0].site[0].serviceList[0].groupType[0].transitionId){
            console.log("ProductList.Site.ServiceList.groupType.transitionId : "+JSON.stringify(transitionList.productList[0].site[0].serviceList[0].groupType[0].transitionId));
        }
        if(selectedMobile[0].Product_Number){
            console.log("ServiceID/FNN : "+JSON.stringify(selectedMobile[0].Product_Number));
        }*/
		
		
        //  alert("Im In mainPage------>" + JSON.stringify(component.get("v.selectedMobileRecrod")));
        let actionMobile = component.get("c.insertJSONResponseMobile");
        //-- Merging response of two or more site recieved from Replicator --
        actionMobile.setParams({
            TransitionDataJSON: component.get("v.mobileTransitionData"),
            selectedList: component.get("v.selectedMobileRecrod"),
            basketId: component.get("v.basketId"),
            SendCallout: true
        });
        actionMobile.setCallback(this, function (response) {
            let mobileTransitionData = response.getReturnValue();
            if (mobileTransitionData) {
                 console.log('********response>'+JSON.stringify(mobileTransitionData));
                component.set("v.loadingSpinner", false);
            } else {
                component.set("v.loadingSpinner", false);
            }
        });
        console.log('mobileTransitionData@@4',JSON.stringify(component.get("v.mobileTransitionData")));
        $A.enqueueAction(actionMobile);
        //----------- Mobile Code------
    },
    getParameterByName: function (name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return "";
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    saveNgUcTransition : function (component, event, helper) {
        component.set("v.loadingSpinner", true);
       // console.log("Im In  NgUCRecrod------>" + JSON.stringify(component.get("v.ngUcTransitionData"))); 
        console.log("Im In selected  NgUCRecrod------>" + JSON.stringify(component.get("v.selectedNgUCRecrod"))); 
        
        let actionNgUc = component.get("c.insertJSONResponseNgUc");
        //-- Merging response of two or more site recieved from Replicator --
        actionNgUc.setParams({
            TransitionDataNgUcJSON: component.get("v.ngUcTransitionData"),
            selectedList: component.get("v.selectedNgUCRecrod"),
            basketId: component.get("v.basketId"),
            SendCallout: true
        });
        actionNgUc.setCallback(this, function (response) {
            let ngUcTransitionData = response.getReturnValue();
            if (ngUcTransitionData) {
               //  alert('********response>'+JSON.stringify(ngUcTransitionData));
                component.set("v.loadingSpinner", false);
            } else {
                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(actionNgUc); 
        /*  
    alert("Im In  NgUCRecrod------>" + JSON.stringify(component.get("v.ngUcTransitionData"))); 
    alert("Im In  NgUCRecrod Selected------>" + JSON.stringify(component.get("v.selectedNgUCRecrod")));
    
            alert("Im In  Mobile------>" + JSON.stringify(component.get("v.mobileTransitionData"))); 
    alert("Im In  Mobile Selected------>" + JSON.stringify(component.get("v.selectedMobileRecrod")));
	*/
    },
    //EDGE-164031 changes by Rahul to dynamically calculate the count Start from Here// 
    getSelectedCount : function (component) {
        let selectedRows = [];
        var tabledataval= component.get("v.mobileResponseTable");
             tabledataval.forEach(function (obj) {
                    if (obj.checkValue == true) {
                        selectedRows.push(obj.Id);
                    }
                });
        component.set("v.selectedRows", selectedRows.length);
        console.log('Selected Rows For selection: '+selectedRows);
        
    },
    getSelectedCountNguc : function (component) {
        let selectedRowsNguc = [];
        var tabledataval= component.get("v.ngUCResponseTable");
             tabledataval.forEach(function (obj) {
                    if (obj.checkValue == true) {
                        selectedRowsNguc.push(obj.Id);
                    }
                });
        component.set("v.selectedRowsNgUC", selectedRowsNguc.length);
        
    },
   //EDGE-164031 changes by Rahul to dynamically calculate the count End Here//  
   
    /* EDGE-168642 Changes by Abhishek from Osaka Team-------START--------- */
    //Logic for Download CSV button on Review and Confirm Screen.
    convertLegacyDataToCSV: function(component, objectRecords){
        //console.log("Object Records: " +objectRecords);
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variable for separate CSV values and 
        // for start next line use '\n' [new line] in lineDivider variable  
        columnDivider = ',';
        lineDivider =  '\n';
 
        
        // API names of the fields
        //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team 
        //EDGE-195976::Pradeep Mudenur:Added CIDN,ABN and BAN
        //Added user_name as a part of EDGE-207157 by Abhishek(Osaka)
        keys = ['source_CIDN','ABN','Product_Number','plan_name','BAN','Plan_Type','contract_remaining_term','Dealer_Code','user_name'];
        
        //Column headers for CSV files
        //EDGE-173831 Replaced contract term with Remaining term by Abhishek from Osaka Team
        //EDGE-195976::Pradeep Mudenur:Added CIDN,ABN and BAN
        //Added Nick Name as a part of EDGE-207157 by Abhishek(Osaka)
        var columnHeaders = ['CIDN','ABN','Service ID','Current Plan','BAN','Plan Type','Remaining Term','Partner Dealer Code','Nickname'];

        csvStringResult = '';
        csvStringResult += columnHeaders.join(columnDivider);
        csvStringResult += lineDivider;
 
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;

             for(var tempKey in keys) {
                var finalKey = keys[tempKey] ;
                 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
                 //console.log("Test++"+objectRecords[i]);

              // csvStringResult += '"'+ objectRecords[i][finalKey]+'"';
                 if(objectRecords[i][finalKey] != undefined){
                      csvStringResult += '"'+ objectRecords[i][finalKey]+'"';
                 }else{
                     csvStringResult += '"'+ '' +'"';
                 }

               counter++;
                 //console.log("Data to download " +csvStringResult); 
            }  
             csvStringResult += lineDivider;
          } 

        //console.log("Data to download " +csvStringResult); 

        return csvStringResult; 
    },
    /* EDGE-168642 -------END--------- */
    
    /* EDGE-177640 Changes by Abhishek from Osaka Team-------START--------- */
    getMROLegacyDetails: function(component,event,helper){
        console.log("Inside Legacy Details");
        var action = component.get("c.getMROLegacyDetails");
        action.setParams({
           TransitionDataJSON: component.get("v.mobileTransitionData"),
           basketId: component.get("v.basketId")
        });
        action.setCallback(this, function(response) {
            let mroDetails = response.getReturnValue();
            console.log("Legacy Details:::::" +JSON.stringify(mroDetails));
            
        });
        $A.enqueueAction(action);
    },
         /* EDGE-177640 -------END--------- */
    confirmSelection : function(component,event,helper){
        var mroData = component.get("v.MROList");
        for (var i =0 ; mroData.length; i++)
        {
            for (var j=0; mroData[i].mrowrapperList.length; j++)
            {
                console.log(mroData[i].mrowrapperList[j].status);
            }
        }
    },
    
   getBOHProfileName: function(component,event,helper){
        
        var action = component.get("c.getProfileInfo");
        
        action.setCallback(this, function(response) {
            let isBohProfile = response.getReturnValue();
            console.log("isBohProfile" + isBohProfile);
			var state = response.getState();
            if (state === "SUCCESS") {
			component.set("v.isBohProfile", isBohProfile);
            }
        });
        $A.enqueueAction(action);
    },
    /* EDGE-168718 changes by Jayghosh Mishra from Osaka Team-------START--------- */
    
    refreshAction: function(component,event,helper){
        var refreshAction = component.get("c.getBasket");
        refreshAction.setParams({
            basketId: component.get("v.basketId")
        });
        refreshAction.setCallback(this, function(response) {
            
            component.set("v.ProdBasket", response.getReturnValue());
            var productBasket = component.get("v.ProdBasket");
            
            console.log('Success BAsket Stage:::' +productBasket.Transition_basket_stage__c);
            
            if(
                productBasket.Transition_basket_stage__c ==
                "Check Eligibility Completed"
            ){
                console.log('Test');
                component.set("v.loadingFixedSpinner", false);
                component.set("v.showProgressRing", false);
              ///  component.set("v.hideCheckboxColumn", true);
			
            var urlToBasket = window.location.href;
            window.location.href = urlToBasket;
    }
    
        });
        $A.enqueueAction(refreshAction);
    },
    /* EDGE-168718 ----------------------END------------------------------- */
    //Start EDGE-200766
    isRequestSupportVisible : function(component,event){


        var mobileResponse = component.get("v.mobileTransitionData");
        console.log('---mobileResponse---'+JSON.stringify(mobileResponse));
        var ngUCResponse = component.get("v.ngUcTransitionData");
        console.log('---ngUCResponse---'+JSON.stringify(ngUCResponse));
        console.log('In request support');

        if (mobileResponse){
        	for (var i =0 ; i < mobileResponse.productList[0].site.length; i++)
        	{
    			if(mobileResponse.productList[0].site[i].serviceList[0].EligibilityStatus!='Eligible'){
    				component.set("v.isRequestSupportdisable",false);
                    console.log("isRequestSupportdisable :"+JSON.stringify(component.get("v.isRequestSupportdisable")));
                    component.set("v.isModalOpen", true);

                	break;
					}
            }
        }else if(ngUCResponse){
            for (var i =0 ; i < ngUCResponse.productList[0].site[0].serviceList[0].groupType.length; i++)
        	{
                if(ngUCResponse.productList[0].site[0].serviceList[0].groupType[i].EligibilityStatus!='Eligible'){
    				component.set("v.isRequestSupportdisable",false);
                    console.log("isRequestSupportdisable :"+JSON.stringify(component.get("v.isRequestSupportdisable")));
                    component.set("v.isModalOpen", true);

                	break;
    				}
            }
        }

    },

    setTransitionId : function (component, event, helper){
        var transitionIdVal = '';
        var mobileResponse = component.get("v.mobileTransitionData");
        var ngUCResponse = component.get("v.ngUcTransitionData");
        var fnnsList = new Array();
        if (mobileResponse){
            for (var i =0 ; i < mobileResponse.productList[0].site.length; i++){
    			if(mobileResponse.productList[0].site[i].serviceList[0].EligibilityStatus!='Eligible'){
                    transitionIdVal = mobileResponse.productList[0].site[i].serviceList[0].groupType[0].transitionId;
                	fnnsList.push(mobileResponse.productList[0].site[i].serviceList[0].groupType[0].service[0].Service_Id);
				}
        	}
        }else if(ngUCResponse){
            for (var i =0 ; i < ngUCResponse.productList[0].site[0].serviceList[0].groupType.length; i++){
    			if(ngUCResponse.productList[0].site[0].serviceList[0].groupType[i].EligibilityStatus!='Eligible'){
                    transitionIdVal = ngUCResponse.productList[0].site[0].serviceList[0].groupType[i].transitionId;
                    for (var j =0 ; j < ngUCResponse.productList[0].site[0].serviceList[0].groupType[i].service.length; j++)
                	fnnsList.push(ngUCResponse.productList[0].site[0].serviceList[0].groupType[i].service[j].Service_Id);
				}
        	}
            
        }
        component.set("v.fnnsList", fnnsList);
        component.set("v.transitionId", transitionIdVal); 
    },
    getCommunityUrl: function(component, event) {
        var action = component.get("c.getCommunityUrl");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                 component.set("v.CommunityUrl", result);
                }
            
        });
        $A.enqueueAction(action);
    },
    //End EDGE-200766

    //EDGE-198375:Fetch tramas error code to show toast
/* pollApex : function(component, event, helper) { 
        console.log("in callapex");
         let intervalId = "";
        var action = component.get("c.getTramsErrorCode");
        var retVal ;
        action.setParams({ 
            "offerType":component.get("v.callFrom"),
            "basketId": component.get("v.basketId"),
            "exetype":"TM1"
        });
        action.setCallback(this, function(response) {
            //this.handleResponse(response, component);
            retVal = response.getReturnValue() ;
           // component.set("v.errorWrap",retVal); 
            console.log("retVal: ",JSON.stringify(retVal));
            if(retVal!=null && (retVal.executiontype!='Execution Error' && retVal.executiontype!='TM0 Execution Error')){
                 window.clearInterval(intervalId);
                 console.log("true:refresh button visible");
                 this.updateProdBasketToCheckEligibility(component, event,helper); //Edge-90158

            }
            else if(retVal!=null){
                window.clearInterval(intervalId);
                
               //component.set("v.ProdBasket.Transition_basket_stage__c",'Check Eligibility Completed');
               component.set("v.loadingFixedSpinner",false);
                
                this.showCustomToast(
                    component,
                    retVal.toastMessage,
                    "",
                    "error"
                );
                component.set("v.isRefreshButtonVisible",false);
            }
        });
        
        if(retVal==null){
            //if( retVal.tramasErrorcode!=null && retVal.tramasErrorcode!=''){
                 intervalId =  window.setInterval(
                    $A.getCallback(function() { 
                        $A.enqueueAction(action); 
                    }), 25000
                );
           // }
            }
        /*if(component.get("v.isRefreshButtonVisible")){
            //console.log("true:refresh button visible");
        }else{
            console.log("false");
        }
    },*/
     pollApex : function(component, event, helper) { 
        console.log("in poll apex");
         var action = component.get("c.getCurrentDatetime");
         action.setCallback(this, function (response) {
  		  var state = response.getState();
             if (state === "SUCCESS") {
                 var currentdate  = response.getReturnValue();
                 console.log("response : ",currentdate);
                 this.pollApexwithDate(component, event, helper,currentdate);
              
        }
            
        });
        $A.enqueueAction(action);
    },
    pollApexwithDate : function(component, event, helper,currentdate) { 
     console.log("in callapex",currentdate);
         let intervalId = "";
        var action = component.get("c.getTramsErrorCode");
        var retVal ;
        action.setParams({ 
            "offerType":component.get("v.callFrom"),
            "basketId": component.get("v.basketId"),
            "exetype":"TM1",
            "currentDate":currentdate
        });
        action.setCallback(this, function(response) {
            //this.handleResponse(response, component);
            retVal = response.getReturnValue() ;
           // component.set("v.errorWrap",retVal); 
            console.log("retVal: ",JSON.stringify(retVal));
            if(retVal!=null && (retVal.executiontype!='Execution Error' && retVal.executiontype!='TM0 Execution Error')){
                 window.clearInterval(intervalId);
                 console.log("true:refresh button visible");
                 this.updateProdBasketToCheckEligibility(component, event,helper); //Edge-90158
                
            }
            else if(retVal!=null){
                window.clearInterval(intervalId);
                
               //component.set("v.ProdBasket.Transition_basket_stage__c",'Check Eligibility Completed');
               component.set("v.loadingFixedSpinner",false);
                
                this.showCustomToast(
                    component,
                    retVal.toastMessage,
                    "",
                    "error"
                );
                component.set("v.isRefreshButtonVisible",false);
            }
        });
        
        if(retVal==null){
            //if( retVal.tramasErrorcode!=null && retVal.tramasErrorcode!=''){
                 intervalId =  window.setInterval(
                    $A.getCallback(function() { 
                        $A.enqueueAction(action); 
                    }), 25000
                );
           // }
            }
    },
 //Start of EDGE-198188 by Abhishek(Osaka) to restrict Migration BOH user from selecting services with different BANs
    validateMultipleBanBoh: function(component,event,helper){
        
        //On screen Selected Records
        var selectedList = component.get("v.selectedMobileRecrod");
        var banList = [];
        var uniqueBanList = [];
        
        selectedList.forEach(function (obj) {	
            banList.push(obj.BAN);
        });

        //Unique List of BANs
        uniqueBanList = [...new Set(banList)];
        console.log('Selected List:::' +selectedList);
        console.log('BAN List::' +banList);
        console.log('Unique Ban List::' +uniqueBanList);
        if(uniqueBanList.length> 1 && component.get("v.isBohProfile") ==  false){
            console.log('Inside BAN List if');
            component.set('v.validateMultipleBan',true);
            component.set('v.openModalBoh', true);
            component.set('v.confirmMessageBoh', $A.get("$Label.c.MultipleBanBohValidation"));
        }
        else{
            component.set('v.validateMultipleBan',false);
            component.set('v.openModalBoh', false);
        }
    },
    // End of EDGE-198188 by Abhishek(Osaka)

            //DIGI-1757 changes by Pradeep from Osaka Team START
            convertLegacyDataToCSVNGUC: function(component, objectRecords){
                //console.log("Temp NGUC Data: "+tempmobileResponseTable);
                //console.log("Object Records: " +objectRecords);
                var csvStringResult, counter, keys, columnDivider, lineDivider;
                // check if "objectRecords" parameter is null, then return from function
                if (objectRecords == null || !objectRecords.length) {
                    return null;
                 }
                // store ,[comma] in columnDivider variable for separate CSV values and 
                // for start next line use '\n' [new line] in lineDivider variable  
                columnDivider = ',';
                lineDivider =  '\n';
         
                
                // API names of the fields.
                keys = ['Product_Type','FNN_Number','Association_Type','contract_term','eligibilityStatus','eligibilityReason'];
                
                //Column headers for CSV files
                var columnHeaders = ['PRODUCT','FNN','TYPE','CONTRACT TERM','ELIGIBILITY STATUS','REASON'];
                csvStringResult = '';
                csvStringResult += columnHeaders.join(columnDivider);
                csvStringResult += lineDivider;
         
                for(var i=0; i < objectRecords.length; i++){   
                    counter = 0;
                     for(var tempKey in keys) {
                        var finalKey = keys[tempKey] ;
                      // add , [comma] after every String value,. [except first]
                          if(counter > 0){ 
                              csvStringResult += columnDivider; 
                           }   
                         //console.log("Test++"+JSON.stringify(objectRecords[i]));
                         // Start of EDGE-181293 - Added null check to avoid undifined for Eligibility Reason
                         if(objectRecords[i][finalKey] != undefined){
                              csvStringResult += '"'+ objectRecords[i][finalKey]+'"';
                         }else{
                             csvStringResult += '"'+ '' +'"';
                         }
                         //End of EDGE-181293
                       counter++;
                         //console.log("Data to download " +csvStringResult); 
                    }  
                     csvStringResult += lineDivider;
                  } 
                //console.log("Data to download " +csvStringResult); 
                return csvStringResult; 
            },
            //DIGI-1757 End.

            //Start of DIGI-1741 by Abhishek(Osaka) to hit validation for Plan Configuration Mode on confirm button
    fetchCustomMetadatata : function(component,event,helper,customDevName){
        var customMetAction = component.get("c.getCustomMetadataRecords");
        customMetAction.setParams({
                metadataDevName: customDevName
            });
            customMetAction.setCallback(this, function(response) {
                var data = response.getReturnValue();
                console.log("$$$$$$$$" + response.getState());
                if(response.getState() == "SUCCESS"){
                if(data != null){
                    console.log('Inside Metadata not null');
                    component.set("v.customMetadatRec",data);
                    console.log('Custom Metadata Record::'+JSON.stringify(component.get("v.customMetadatRec")));
                    
                }
                else{
                    console.log('Data null:'+data);
                }
            }
                
            });
            $A.enqueueAction(customMetAction);
    },
    //End of DIGI-1741 by Abhishek(Osaka) 
     /*DIGI-1939-Dheeraj Bhatt-Enable an API call to the MS to initiate digi plan configuration*/
     handleConfirm:function(component,event,helper){
        component.set("v.sioModal", false);
        component.set("v.loadingSpinner", true);
        var action = component.get("c.autoSIOConfig");
        action.setParams({ 
            "basketId": component.get("v.basketId")
        });
        action.setCallback(this, function(response) {
            var isSuccess=response.getReturnValue();
            if(response.getState() === "SUCCESS") {
                if(isSuccess ==false){
                    this.showCustomToast(component,$A.get("$Label.c.orderLodgmentApiFailure"),"", "error"); 
                }
            }
             component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
    }

})