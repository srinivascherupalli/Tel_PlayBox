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
    doInit: function(component, event, helper) {
        console.log("doInit");
        console.log('ComparisonUtility_V2:::'+component.get("v.isCidnHierarchy"));
        console.log("isOnScreenRetrieval",component.get("v.isOnScreenRetrieval"))
		helper.getCommunityUrl(component,event);//EDGE-200766
        var allServicesClickedVar = new Map();
        allServicesClickedVar['mobileClicked'] = false;
        allServicesClickedVar['ngUcClicked'] = false;
        component.set("v.allServicesClicked", allServicesClickedVar);
        
        component.set("v.loadingSpinner", true);
        component.set("v.ifInTranstion", true);
        //helper.getReviewConfirmData(component, event, helper);
        //var basketId = component.get("v.basketIDURL");
        // var basketId = window.location.href.split("=")[1].substring(0, 18);
        var basketId = helper.getParameterByName("id", window.location.href);
        console.log("basketId: ",basketId);
        var isMobilityProduct = helper.getParameterByName(
            "isMobilityProduct",
            window.location.href
        );
        component.set("v.basketId", basketId);
        component.set("v.isMobilityProduct", isMobilityProduct);
        var action = component.get("c.fetchSiteFromBasketControllerMap");
        action.setParams({
            basketId: component.get("v.basketId")
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if (response.getState() == "SUCCESS" && data !=
                null) {
                component.set("v.siteDTOMap", data);
                helper.getBasket(component);
                var childCmp = component.find("GetSiteComp");
                if(childCmp!=null || childCmp!=undefined){
                    childCmp.displaySites();
                }
                
                
                //helper.getBasket(component);
            }
        });
        $A.enqueueAction(action);
        
        //START OF EDGE-199057 by Abhishek from Osaka Team to check for eligibility completion post clicking on Check eligibility
            var actionMobile = component.get("c.getEligibilityStatusMobile");
            actionMobile.setParams({
                basketId: component.get("v.basketId")
            });
            actionMobile.setCallback(this, function(response) {
                var data = response.getReturnValue();
                console.log("$$$$$$$$" + response.getState());
                if(response.getState() == "SUCCESS"){
                if(data != null){
                    console.log('Data not null:'+data);
                    if (data == false){
                        console.log('Data false');
                        component.set("v.loadingFixedSpinner", true);
                        component.set("v.checkEligibilityInprogress", true);
                        component.set("v.showProgressRing", true);
                        component.set("v.showRing", true);
                        component.set("v.displayTransBtn", false);
                    }
                    else{
                        console.log('Data true:'+data);
                        //Setting this flag to true if check eligibility is completed for Mobile
                        component.set("v.eigibilityCheckFromMobile",true);
                    }
                }
                else{
                    console.log('Data null:'+data);
                    //Setting this flag to true if check eligibility is completed for Mobile
                    component.set("v.eigibilityCheckFromMobile",true);
                }
            }
                
            });
            $A.enqueueAction(actionMobile);
            //END OF EDGE-199057 by Abhishek from Osaka Team
            if(component.get("v.eigibilityCheckFromMobile") == true){
        var action1 = component.get("c.getEligibityStatus");
        action1.setParams({
            basketId: component.get("v.basketId")
        });
        action1.setCallback(this, function(response) {
            var data = response.getReturnValue();
            console.log("$$$$$$$$" + response.getState());
            if (response.getState() == "SUCCESS" && data !=
                null) {
                console.log("Inside If");
                console.log(data);
                var statusMap = Object.entries(data);
                if (data.length >= 4 && data[3] == 1 && data[2] ==
                    0) {
                    component.set("v.value", data[1]);
                    component.set("v.valuemax", data[0]);
                    component.set("v.loadingFixedSpinner", true);
                    component.set(
                        "v.checkEligibilityInprogress",
                        true);
                    component.set("v.showProgressRing", true);
                    component.set("v.showRing", true);
                    component.set("v.displayTransBtn", false);
                }
            }
        });
        $A.enqueueAction(action1);
            }
        //edge -90448 start
        /*var productBasket=component.get("v.ProdBasket");
        console.log('****' +productBasket);
        //console.log('****' +productBasket.Transition_basket_stage__c);
            if(productBasket!=null){
                if(productBasket.Transition_basket_stage__c=='Check Eligibility Triggered'){
                    component.set("v.loadingFixedSpinner",true);
                }else if(productBasket.Transition_basket_stage__c=='Modify Selected'){
                    component.set("v.hideCheckboxColumn",false);
                    component.set("v.loadingFixedSpinner",fasle);
                }else if(productBasket.Transition_basket_stage__c=='Check Eligibility Completed'){
                    component.set("v.hideCheckboxColumn",true);
                    component.set("v.loadingFixedSpinner",false);
                    helper.reviewConfirmedDisabledCalculateHelper(component, event, helper);
                }                   
            }*/
        //edge -90448 end
        component.set("v.columns", helper.getColumnDefinitions());
        //helper.updateProdBasketToCheckEligibility(component,event,helper);
        //component.set("v.loadingSpinner", false);
        //helper.reviewConfirmDisabledHelper(component,event,helper);
        helper.getBOHProfileName(component,event,helper);
        //DIGI-1741 by Abhishek(Osaka) to hit validation for Plan Configuration Mode on confirm button
        helper.fetchCustomMetadatata(component,event,helper,'MTM_Metadata_Utility__mdt');
        
    },
    // event method handleGetSelectedProduct
    handleGetSelectedProduct: function(component, event, helper) {
        var selectedProduct = event.getParam("selectedProduct");
        var siteMap2 = new Map();
        siteMap2 = event.getParam("sitesMap_V2");
        component.set("v.sitesMap_V2", siteMap2);
    },
    processTransition: function(component, event, helper) {
        var callSelectedProduct = $A.get("e.c:CallGetSelectedProduct");
        callSelectedProduct.fire();
        //helper.showCustomToast(component, 'Legacy Services for transition, successfully added to Product Basket. Please Close this window', 'Finished', helper.SUCCESS);
    },
    handleSaveButtonOnTabClick: function(component, event, helper) {
        var tabName = event.getParam("tabName");
        if (
            tabName == "GetService" &&
            component.get("v.ProdBasket.csordtelcoa__Basket_Stage__c") ==
            "Commercial Configuration"
        ) {
            //component.set("v.displayTransBtn",true);
        } else if (tabName == "ExistingSubscription") {
            component.set("v.displayTransBtn", false);
        }
    },
    gotoAccount: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: component.get(
                "v.ProdBasket.csbb__Account__c")
        });
        navEvt.fire();
    },
    gotoOpportunity: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: component.get(
                "v.ProdBasket.cscfga__Opportunity__c")
        });
        navEvt.fire();
    },
    gotoUser: function(component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            recordId: component.get("v.ProdBasket.CreatedById")
        });
        navEvt.fire();
    },
    //checkeligibility button
    checkEligibility: function(component, event, helper) {
        //component.set("v.displayTransBtn", false);

        //Added as a part of EDGE-198188 by Abhishek(Osaka) to restrict Migration BOH user from selecting services with different BANs
        helper.validateMultipleBanBoh(component,event,helper);
        
        //Added(if condition) as a part of EDGE-198188 by Abhishek(Osaka) to restrict Migration BOH user from selecting services with different BANs

        if(component.get("v.validateMultipleBan") == false){

        var mobileNumberList = [];
        console.log("selectedMobileRecrod: ",JSON.stringify(component.get("v.selectedMobileRecrod")));
         console.log("mobileTransitionData: "+component.get("v.mobileTransitionData"));
         console.log("selectedNgUCRecrod: "+JSON.stringify(component.get("v.selectedNgUCRecrod")));
          console.log("ngUcTransitionData: "+component.get("v.ngUcTransitionData"));
         console.log("MROList "+component.get("v.MROList"));
        var selectedMobileRecrod = component.get("v.selectedMobileRecrod");
        if(selectedMobileRecrod!=null){
             selectedMobileRecrod.forEach(function(record) {
            mobileNumberList.push(record.Product_Number);
        	});
            console.log('mobileNumberList',mobileNumberList);
        }
        
        if (component.get("v.siteClickedFlag") == false) {
            var msg =
                "Please review all the site(s) before eligibility check.";
            helper.showCustomToast(component, msg, "Error", helper.ERROR);
            component.set("v.loadingSpinner", false);
            return;
        }
        
        var msg =
            "This request may take some time, and not be completed within this session.";
        helper.showCustomToast(component, msg, "Finished", helper.SUCCESS);
        component.set("v.checkEligibilityInprogress", true);
        component.set("v.loadingFixedSpinner", true);
        component.set("v.showProgressRing", true);
        component.set("v.displayTransBtn", false);
        component.set("v.sendCalloutBoolean", true);
        //helper.updateProdBasketToCheckEligibility(component, event,helper); //Edge-90158
        helper.processTransition(component, event, helper);
        let sendCallout = true;
        
        // helper.selectedDTO_V2(component, event, helper, sendCallout);
        helper.saveMobileTransition(component, event, helper);
        helper.saveNgUcTransition(component, event, helper);
        helper.selectedDTO_V2(component, event, helper, true);
       helper.pollApex(component, event, helper);//EDGE-198375
       helper.isRequestSupportVisible(component,event);//EDGE-200766
        }
    },

    // confirm and review button
    navigateToReviewConfirm: function(component, event, helper) {
       // alert("Hi");
       // alert(component.get("v.isMobilityProduct"));
       // alert(clickedBtn);
       // alert(checkForBohUser);
        var clickedBtn = event.getSource().getLocalId();
	    console.log('mobileTransitionData@@',JSON.stringify(component.get("v.mobileTransitionData")));        helper.getMROLegacyDetails(component,event,helper); //EDGE-177640 by Abhishek-Osaka Team
        
        //Start of EDGE-188078	:	Skipping the MRO screen for BOH user- Migration scenario Jayghosh Mishra(Osaka Team)
        var checkForBohUser = component.get("v.isBohProfile"); 
            console.log("isMobility", component.get("v.isMobilityProduct"));
            console.log("clickedBtn", clickedBtn);
            console.log("checkForBohUser", checkForBohUser);
        console.log('mobileTransitionData@@',JSON.stringify(component.get("v.mobileTransitionData")));
        //EDGE-218979 - Reverted EDGE-208434 for FDR fix(removing checkForBohUser == true) by Abhishek(Osaka) -On behalf of Cairo.
        if(component.get("v.isMobilityProduct") == "true" & clickedBtn != 'review')
            //End of EDGE-188078
        {
          //  console.log('isMobility', component.get("v.isMobilityProduct"));
          //  console.log('clickedBtn', clickedBtn);
          //  console.log('checkForBohUser', checkForBohUser);
            component.set("v.spinner", true);
            console.log('basket',component.get("v.basketId"));
            debugger;
            var action = component.get("c.getMRODetails");
            action.setParams({
                basketId: component.get("v.basketId"),
                
                searchFinalVal: component.get("v.searchFinalVal"),
                
            });
            action.setCallback(this, function(response) {
                //START: Modified for EDGE-224107
                //var result =response.getReturnValue();
                var result =JSON.parse(response.getReturnValue());
                //END for EDGE-224107
                component.set("v.MROList",result);
                console.log('MRO/ARO Data::'+JSON.stringify(result));
                if (result.length > 0) {
                    component.set("v.activelwcSection",result[0].serviceStr);
                }
                console.log('MRO data',result);
                component.set("v.spinner", false);
                
            });
            $A.enqueueAction(action);
            
            component.set("v.checkReviewConfirm", false);
            component.set("v.ifInTranstion", false);
            
            component.set("v.checkEligibilityComplete", true);
            
            component.set("v.MROScreenenabled", true);
            
        }
        
        else
        { 
            component.set("v.loadingSpinner", true);
            component.set("v.MROScreenenabled", false);
            component.set("v.checkReviewConfirm", true);
            component.set("v.ifInTranstion", false);
            component.set("v.checkEligibilityComplete", false);
            var sendCallout = false;
            
            //helper.getReviewConfirmData(component, event, helper);
            helper.selectedDTO_V2(component, event, helper, false);
            helper.openReviewConfirm(component, event);
            //component.set("v.loadingSpinner", false);
        }
    },
    //START: request support button : EDGE-200766
	isRequestSupportVisible:function(component, event, helper) {
        helper.isRequestSupportVisible(component, event);
    },
    requestSupport: function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        helper.setTransitionId(component, event, helper);
        
        var basketIdVal = component.get("v.basketId"); 
        var cidnNumberVal = component.get("v.ProdBasket.csbb__Account__r.CIDN__c"); 
        var transactionIdVal = component.get("v.transitionId");
        var fnnListVal = component.get("v.fnnsList"); 
       
        var action = component.get("c.feedbackCase"); 
        action.setParams({"basketId": basketIdVal,
                          "cidnNumber": cidnNumberVal,
                          "transactionId": transactionIdVal, 
                          "fnnList": JSON.stringify(fnnListVal)});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var caseRec = response.getReturnValue();
               
                component.set("v.caseId",caseRec.Id);
                component.set("v.CaseNumber",caseRec.CaseNumber);
                component.set("v.isCaseCreated",true);  
                component.set("v.isCaseModalOpen", true);                
                component.set("v.loadingSpinner", false);
            }
            else if (state === "ERROR") {

                component.set("v.loadingSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },

   handleClick : function(component, event, helper) {
       
		var recordId = component.get("v.caseId");
        console.log('caseRec Id@@' + recordId);
        var communityUrl = component.get('v.CommunityUrl');
        if(communityUrl == null || communityUrl == ''){
        window.open('/' + recordId,'_blank');       
        }
        else{
            window.open(communityUrl+'s/case/'+ recordId,'_blank');
        }   
    },

    closeModel: function(component, event, helper) {      
        component.set("v.isCaseModalOpen", false);
    },
    //END: request support button : EDGE-200766

    //modify selection button
    modifySelected: function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        component.set("v.isDisabled", false);
        //component.set("v.loadingFixedSpinner",false);
        component.set("v.displayTransBtn", false);
        helper.updateProdBasketToModifySelection(component, event,
                                                 helper);
        var productBasket = component.get("v.ProdBasket");
        if (productBasket != null) {
            if (productBasket.Transition_basket_stage__c ==
                "Modify Selected") {
                component.set("v.loadingFixedSpinner", false);
                component.set("v.showProgressRing", false);
                component.set("v.hideCheckboxColumn", false);
            }
        }
        //$A.get('e.force:refreshView').fire();
        var urlToBasket = window.location.href;
        window.location.href = urlToBasket; 
    },
    // refresh button logic
    refreshLoader: function(component, event, helper) {
        component.set("v.showRing", true);
        component.set("v.loadingFixedSpinner", true);
        //START OF EDGE-199057 by Abhishek from Osaka Team to refresh the page only if Check eligibility is completed post clicking on Check Eligibility Button
        var callFrom = component.get("v.callFrom");
        if(callFrom == 'Mobility'){ 
            console.log('Inside Mobile');
            var actionMobile = component.get("c.getEligibilityStatusMobile");
            actionMobile.setParams({
                basketId: component.get("v.basketId")
            });
            actionMobile.setCallback(this, function(response) {
                var data = response.getReturnValue();
                console.log('Return Value from MobileTramas::' +data);
            });
            $A.enqueueAction(actionMobile);
        }
        //END OF EDGE-199057 by Abhishek from Osaka Team
        else{
            console.log('Inside Nguc');
        var action = component.get("c.getEligibityStatus");
        action.setParams({
            basketId: component.get("v.basketId")
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if (response.getState() == "SUCCESS" && data !=
                null) {
                var statusMap = Object.entries(data);
                component.set("v.value", data[1]);
                component.set("v.valuemax", data[0]);
                var productBasket = component.get("v.ProdBasket");
            }
            if (data[0] == data[1]) {
                    console.log('Inside Spinner stop');
                component.set("v.checkEligibilityInprogress",false);
                component.set("v.checkEligibilityComplete", true);
                component.get("v.checkEligibilityComplete");
                component.set("v.displayTransBtn", false);
                // logic to stop spinner and based on number status disable review button
            } else {
                component.set("v.showProgressRing", true);
            }
        });
        $A.enqueueAction(action);
            }
        /* EDGE-168718 changes by Jayghosh Mishra from Osaka Team-------START--------- */
        //helper.refreshAction(component,event,helper);
 	   // Commented as part of EDGE-198927
            /*var urlToBasket = window.location.href;
            window.location.href = urlToBasket; */
        /* EDGE-168718 ----------------------END------------------------------- */
        /*
        //added for edge -90448
        if (productBasket != null) {
            if (
                productBasket.Transition_basket_stage__c ==
                "Check Eligibility Completed"
            ) {
				console.log('inside eligibility check--->>>');
                component.set("v.loadingFixedSpinner", false);
                component.set("v.showProgressRing", false);
                component.set("v.hideCheckboxColumn", true);
            }
        } */
        helper.refreshAction(component,event,helper);
        helper.reviewConfirmedDisabledCalculateHelper(component, event,
                                                      helper);
    },
    //save selection to store json data
    saveSelection: function(component, event, helper) {
        var callFrom = component.get("v.callFrom");//Added as a part of DIGI-18348 by Abhishek(Osaka)
        //Added as a part of EDGE-198188 by Abhishek(Osaka) to restrict Migration BOH user from selecting services with different BANs
        helper.validateMultipleBanBoh(component,event,helper);

        //Added(if condition) as a part of EDGE-198188 by Abhishek(Osaka) to restrict Migration BOH user from selecting services with different BANs
        
        if(component.get("v.validateMultipleBan") == false){
        helper.processTransition(component, event, helper);
        var sendCallout = false;
        component.set("v.loadingSpinner", true);
        if (component.get("v.siteClickedFlag") == true) {
            helper.selectedDTO_V2(component, event, helper, sendCallout);
            if(callFrom = 'Mobility'){
                console.log('Inside Mobile if');
               helper.saveMobileTransition(component, event, helper); 
            }
            else{ 
                helper.saveNgUcTransition(component, event, helper);
            }
            var msg =
                "All Legacy Services selected for transition will be saved. You can continue to update your selections.";
            helper.showCustomToast(component, msg, "Finished", 'SUCCESS');
            setTimeout(function(){
                component.set("v.enableCEButton", false); 
                component.set("v.enableSaveSelButton", true);
            }, 7000);
        } else {
            var msg =
                "Please review all the site(s) before saving the response.";
            helper.showCustomToast(component, msg, "Error", helper.ERROR);
            component.set("v.loadingSpinner", false);
        }
        
        //  alert("Im In mainPage------>"+JSON.stringify(component.get("v.selectedMobileRecrod")) +'*****> '+JSON.stringify(component.get("v.mobileTransitionData")));
        }
        
    },
    //go back to modify selection screen from review and confirm screen
    goBack: function(component, event, helper) {
        component.set("v.checkReviewConfirm", false);
        //component.set("v.ifInTranstion", true);
        component.set("v.loadingSpinner", true);
        component.set("v.ifInTranstion", true);
        //  alert('*****'+component.get("v.basketId"));
        // var basketId = window.location.href.split("=")[1].substring(0, 18);
        // component.set("v.basketId", basketId);
        var action = component.get("c.fetchSiteFromBasketControllerMap");
        action.setParams({
            basketId: component.get("v.basketId")
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if (response.getState() == "SUCCESS" && data !=
                null) {
                component.set("v.loadingSpinner", false);
                component.set("v.siteDTOMap", data);
                var childCmp = component.find("GetSiteComp");
                if(childCmp!=undefined){
                    childCmp.displaySites();
                    
                }
                helper.getBasket(component, event, helper);
                //helper.reviewConfirmDisabledHelper(component,event,helper);
                helper.buttonvaluemapHelpetr(component, event,
                                             helper);
            }
        });
        $A.enqueueAction(action);
        var action1 = component.get("c.getEligibityStatus");
        action1.setParams({
            basketId: component.get("v.basketId")
        });
        action1.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if (response.getState() == "SUCCESS" && data !=
                null) {
                var statusMap = Object.entries(data);
                if (data[4] == 1 && data[3] == 0) {
                    component.set("v.value", data[1]);
                    component.set("v.valuemax", data[0]);
                    component.set("v.loadingFixedSpinner", true);
                    component.set(
                        "v.checkEligibilityInprogress",
                        true);
                    component.set("v.showProgressRing", true);
                    component.set("v.showRing", true);
                    component.set("v.displayTransBtn", false);
                }
            }
        });
        $A.enqueueAction(action1);
        helper.updateProdBasketToModifySelection(component, event, helper);
        var urlToBasket = window.location.href;
        // alert("Im In urlToBasket------>" + JSON.stringify(urlToBasket));
        
        
    },
    
    //navigate to basket
    navigateToRollCall: function(component, event, helper) {
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
    handleGetServicesEvent: function(component, event, helper) {
        //  alert("event ---> " + event.getParam("allSiteClickedFlag"));
        component.set("v.siteClickedFlag", event.getParam("allSiteClickedFlag"));
    },
    mobileSelectionCompleted: function(component, event, helper) {
        //  alert('event ---> '+event.getParam("allSiteClickedFlag"));
        //  alert(component.get("v.isMobilityProduct") + 'event ---> '+JSON.stringify(component.get("v.allServicesClicked")));
        let params = event.getParams();
        console.log('callFrom'+params.callFrom);
        if (params.callFrom == 'Mobility') {
            component.set("v.selectedMobileRecrod", params.SelectedMobileRecrod);
            component.set("v.mobileTransitionData", params.mobileTransitionData);
             component.set("v.callFrom", params.callFrom);
            console.log('callFrom'+params.callFrom);
            //Start of INC000097758809 : To enable Save Selection button onclick of checkbox on Transition Screen by Abhishek(Osaka)
            component.set("v.enableCEButton", true); 
            component.set("v.enableSaveSelButton", false);
            //End of INC000097758809

            
        } else {
            component.set("v.selectedNgUCRecrod", params.SelectedNgUCRecrod);
            component.set("v.ngUcTransitionData", params.ngUcTransitionData);
            //Start of INC000097758809 : To enable Save Selection button onclick of checkbox on Transition Screen by Abhishek(Osaka)
            component.set("v.enableCEButton", true); 
            component.set("v.enableSaveSelButton", false);
            //End of INC000097758809
        }
        
        // alert("Im In mainPage------>"+JSON.stringify(params.SelectedMobileRecrod) +'*****> '+JSON.stringify(params.mobileTransitionData));
    },
    /* EDGE-168642 changes by Abhishek from Osaka Team-------START--------- */
    downloadCSV : function (component, event, helper){
        var legacyData = component.get("v.mobileResponseTable");
        //console.log('Table Data' +legacyData);
        var legacyDataConverted = helper.convertLegacyDataToCSV(component, legacyData);
        if(legacyDataConverted ==  null){
            return;
            
        }
        //Get current date and time
        var currentdate = new Date(); 
        var fileDate =  String(currentdate.getDate()).padStart(2,'0') + String((currentdate.getMonth()+1)).padStart(2,'0') + String(currentdate.getFullYear());
        var elementLink=document.createElement('a');
        elementLink.href='data:text/csv;charset=utf-8,'+encodeURI(legacyDataConverted);
        elementLink.target='_self';
        elementLink.download=$A.get("$Label.c.csvFileLabel")+fileDate+'.csv';
        document.body.appendChild(elementLink);
        elementLink.click(); 
        
    },
    
    /* EDGE-168642 -------END--------- */
    confirmSelection: function(component, event, helper) {
        var selectStatus=[];
        var unselectStatus=[];
        
        var action = component.get("c.getMROConfirmDetails");
        action.setParams({
            basketId: component.get("v.basketId")});          
        action.setCallback(this, function(response) {
            var result =response.getReturnValue();
            //console.log("result",result);
            var selectedService=[];
            var unselectedService=[];
            
            for(var i=0;i<result.length;i++){
                if (result[i].Select__c === true){
                    selectedService.push(result[i].Service_Add_Ons__r);
                }else
                {
                    unselectedService.push(result[i].Service_Add_Ons__r);
                    
                }
                
            }
            console.log(selectedService.length);
            for (var j=0;j<selectedService.length;j++)
            {
                if (selectedService[j] != undefined){     
                    console.log(selectedService[j].length); }
                
            }
            
            
        });
        $A.enqueueAction(action);
        
    }, 
    
    
    // EDGE-180109 : Handling validation on Click on Confirm Button 
    handleOpenModal: function(component, event, helper) {
        event.preventDefault();
        
        var checkMobility=component.get("v.isMobilityProduct");
      
       if(checkMobility=='false')
       {
        console.log("for nguc");
        // var myEvent = $A.get("e.c:TransitionModalCloseEvent");
        //     myEvent.setParams({
        //         "closeTranModal":"false"
                
        //     });
        //     myEvent.fire();
       }
       else{
        
        var validationMessage =  $A.get("$Label.c.TransitionValidation");           
        component.set("v.ConfirmMessage",validationMessage);
        var action = component.get("c.getMROConfirmDetails");
        action.setParams({
            basketId: component.get("v.basketId")});          
        action.setCallback(this, function(response) {
            var result =response.getReturnValue();
            console.log("result",result);
            var selectedService=[];
            var unselectedService=[];
            for(var i=0;i<result.length;i++){
                if (result[i].Service_Add_Ons__r != undefined)
                {
                    for (var j=0;j<result[i].Service_Add_Ons__r.length;j++)
                    {
                        if (result[i].Select__c === true){
                            selectedService.push(result[i].Service_Add_Ons__r[j].Status__c);
                        }
                        else{                            
                            unselectedService.push(result[i].Service_Add_Ons__r[j].Status__c);
                        }           
                    }                        
                }
            }
            
            console.log(unselectedService);
            console.log(selectedService);
            
            
            if( selectedService.length >0 )
            { 
                for (var i=0; i<selectedService.length;i++)
                {
                    if(selectedService[i] != "Sync Completed") {
                        component.set("v.openModal", true);
                    }
                }
            }                    
            if( unselectedService.length >0 )
            { 
                for (var i=0; i<unselectedService.length;i++)
                {
                    if(selectedService[i] != "Sync Removal Pending") {
                        component.set("v.openModal", true);
                    }
                }
            }
            
            //Start of DIGI-1741 by Abhishek(Osaka) to hit validation for Plan Configuration Mode on confirm button
            console.log('Inside Auto Config');
            console.log('Auto Config Value::' +component.get("v.planConfigMode"));
            var confirmMessage = component.get("v.customMetadatRec");
            console.log('Testt::'+confirmMessage['ConfirmMessagePlanConfig'].Value__c);
            if(component.get("v.planConfigMode") == 'Auto SIO' && component.get("v.ProdBasket.cscfga__Opportunity__r.Type") == 'Migration'){
                component.set("v.popUpMessage",confirmMessage['ConfirmMessagePlanConfig'].Value__c);
                component.set("v.sioModal", true);
            }
            //End of DIGI-1741 by Abhishek(Osaka)
            
        });
        $A.enqueueAction(action);          
    }
        
    },
    
    handleCloseModal: function(component, event, helper) {
        //For Close Modal, Set the "openModal" attribute to "fasle"  
        component.set("v.openModal", false);
        //Added as a part of EDGE-198188 by Abhishek(Osaka) to restrict Migration BOH user from selecting services with different BANs
        component.set("v.openModalBoh", false);
    },
    //DIGI-1757 changes by Pradeep from Osaka Team START
    downloadCSVNGUC : function (component, event, helper){
        var legacyData = component.get("v.ngUCResponseTable");
        console.log('NGUC Table Data' +JSON.stringify(legacyData));
        var legacyDataConverted = helper.convertLegacyDataToCSVNGUC(component, legacyData);
        if(legacyDataConverted ==  null){
            return;
        }
        //Get current date in ddmmyyyy format
        var currentdate = new Date(); 
        var fileDate =  String(currentdate.getDate()).padStart(2,'0') + String((currentdate.getMonth()+1)).padStart(2,'0') + String(currentdate.getFullYear());
        
        var elementLink=document.createElement('a');
        elementLink.href='data:text/csv;charset=utf-8,'+encodeURI(legacyDataConverted);
        elementLink.target='_self';
        elementLink.download=$A.get("$Label.c.csvFileLabel")+fileDate+'.csv';
        document.body.appendChild(elementLink);
        elementLink.click();
        
    },
    //DIGI-1757 End

    //Start of DIGI-1741 by Abhishek(Osaka) to hit validation for Plan Configuration Mode on confirm button
    handleCancel: function(component, event, helper) {
        component.set("v.sioModal", false);
    },
    
    //End of DIGI-1741 by Abhishek(Osaka) to hit validation for Plan Configuration Mode on confirm button
/*DIGI-1939-Dheeraj Bhatt-Enable an API call to the MS to initiate digi plan configuration*/
    handleConfirm:function(component,event,helper){
    helper.handleConfirm(component,event,helper);
    }
   
});