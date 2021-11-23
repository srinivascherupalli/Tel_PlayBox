({
    SUCCESS: "success",
    ERROR: "error",
    
    init: function (component, event, helper) {        
		var checkOnLoad = true;
        this.getTransitionBasketStatus(component, event, helper, checkOnLoad);
        
    },

/*EDGE-195766 - to check the transition status and display service numbers based on TM2 response*/
    getTransitionBasketStatus: function (component, event, helper, checkOnLoad){
      var action = component.get("c.getBasket");
        var basketId = component.get("v.basketId");
        action.setParams({
            basketId: basketId
        });
        action.setCallback(this, function (response) {
            component.set("v.ProdBasket", response.getReturnValue());
            var productBasket = component.get("v.ProdBasket");
            console.log('@V@ Transition Basket Status:::' +productBasket.Transition_basket_stage__c);
            component.set("v.isEnabled", false);
            if(productBasket.Transition_basket_stage__c == "Reservation Completed" || productBasket.Transition_basket_stage__c == "Reserved with Errors"){
                component.set("v.isEnabled", true);
                this.populateServiceNumbers(component, event, helper, checkOnLoad);                
            }   
           });
        $A.enqueueAction(action); 
	},
    
    /* EDGE-195766 Moved existing init method flow inside if condition, in-order to stop the displaying of Numbers on load of Page Starts*/
    populateServiceNumbers: function (component, event, helper, checkOnLoad){  
        component.set("v.loadingFixedSpinner", true);
        component.set("v.transitionList",'');
        var action = component.get("c.getServiceNumber");
        action.setParams({ "basketId": component.get("v.basketId") });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                let mobileDataListMain = [];
                let ngUceDataListMain = [];
                let isMobileTransition = false;
                if(component.get("v.selectedTab") == 'Mobile'){
                 isMobileTransition = true;
                }
                response.getReturnValue().forEach(function (objState) {
                    if (objState.productFamily == "Enterprise Mobility") {                       
                        mobileDataListMain.push({
                            "Service_Id": objState.Service_Id,
                            "Id":objState.Service_Id,/* EDGE-203927 */
                            "Reserve_status": objState.Reserve_status,
                            "Reason": objState.Reason,
                            "isSelected": objState.isSelected,
                            "productConfigId": objState.productConfigId,
                            "transitionId": objState.transitionId,
                            "CIDN": objState.CIDN_Number, //EDGE-198374: Added New Column
                            "FNN": objState.FNN_Number, //EDGE-198374: Added New Column
                            "basketId": objState.basketId,
                            "physicalId": objState.physicalId,
                            "networkId": objState.networkId,
                            "fromNumber": objState.fromNumber,
                            "toNumber": objState.toNumber,
                            "accountId": objState.accountId,
                            "service_type": objState.service_type,
                            "planType": objState.planType,
                            "currentPlan": objState.currentPlan, //EDGE-168704: Added New Column
                            "productFamily": objState.productFamily,
                            "tramasStatus" : objState.tramasStatus,
                            "tramasReason" : objState.tramasReason,
                            "isgreyedout":objState.isgreyedout //EDGE-203928 Kalashree Borgaonkar. show greyed out row
                        });
                        
                    } else {
                        ngUceDataListMain.push({
                            "Service_Id": objState.Service_Id,
                            "Id":objState.Service_Id,/* EDGE-203927 */
                            "Reserve_status": objState.Reserve_status,
                            "Reason": objState.Reason,
                            "isSelected": objState.isSelected,
                            "productConfigId": objState.productConfigId,
                            "transitionId": objState.transitionId,
                            "CIDN": objState.CIDN_Number, //EDGE-198374: Added New Column
                            "FNN": objState.FNN_Number, //EDGE-198374: Added New Column
                            "basketId": objState.basketId,
                            "physicalId": objState.physicalId,
                            "networkId": objState.networkId,
                            "fromNumber": objState.fromNumber,
                            "toNumber": objState.toNumber,
                            "accountId": objState.accountId,
                            "service_type": objState.service_type,
                            "planType": objState.planType,
                            "currentPlan": objState.currentPlan, //EDGE-168704: Added New Column
                            "productFamily": objState.productFamily,
                            "tramasStatus" : objState.tramasStatus,
                            "tramasReason" : objState.tramasReason,
                            "isgreyedout":objState.isgreyedout,    //EDGE-203928 Kalashree Borgaonkar. show greyed out row                    
                            "ADBOR_Id" : objState.ADBOR_Id, //Add by Nikhil EDGE-217339 as part of B2B 1260
                            "assignedTo":objState.assignedTo //DIGI-1944
                        });
                    }
                });
                
                if(isMobileTransition == false){
                    component.set("v.transitionList", ngUceDataListMain);
                }
                else{
                    component.set("v.transitionList", mobileDataListMain);
                }              
               component.set("v.loadingFixedSpinner", false);  
            }
            else if (state === "ERROR") {
                component.set("v.loadingFixedSpinner", false);
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
            
            this.showRequestSupport(component, event, helper, checkOnLoad);
        });
        $A.enqueueAction(action);
    },
    /*Moved existing init method flow inside if condition, in-order to stop the displaying of Numbers on load of Page Ends*/  
    
//START EDGE-198374
    showRequestSupport: function (component, event, helper, checkOnLoad) {
        var transitionList = component.get("v.transitionList");
        var fnnsList = new Array();
        var cidnVal = '';
        var transitionIdVal = '';		
        
        for(var i=0; i<transitionList.length; i++){
            
            if(transitionList[i].tramasStatus != 'Completed' && transitionList[i].tramasStatus != ''){
                fnnsList.push(transitionList[i].FNN);
                cidnVal = transitionList[i].CIDN;
                transitionIdVal = transitionList[i].transitionId;
                if(component.get("v.isEnabled") != false){
                    component.set("v.isEnabled", false); 
                } 
                
                component.set("v.isreqSupportEnabled", false); 
            }         
        }
        
        component.set("v.fnnsList", fnnsList);
        component.set("v.cidn", cidnVal);
        component.set("v.transitionId", transitionIdVal); 
        
        /* EDGE-195766 toast starts here */
        if(component.get("v.isEnabled") == false && checkOnLoad == false){
            if(component.get("v.selectedTab") == 'Mobile'){
                //toast failure
                this.showCustomToast(
                    component,
                    $A.get("$Label.c.TM2MobileFailureResponse"),
                    "",
                    "error"
                );
                return;
            }
        }else if(component.get("v.isEnabled") == true && checkOnLoad == false){
            //sucess
            this.showCustomToast(
                component,
                $A.get("$Label.c.TM2SuccessResponseMsge"),
                "",
                "Success"
            );
        }
        /* EDGE-195766 toast Ends here */
        
    },    
    //End of EDGE-198374
    
    showgenericToast : function(component, event, helper,toastTitle,toastType,toastMessage) {
        console.log('showgenericToast@@');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": toastTitle,
            "type" : toastType,
            "mode" : 'dismissible',
            "duration" : 5000,
            "message": toastMessage
        });
        toastEvent.fire();
    },
    
    // EDGE-195766 - Created new methodS 'getServicesHelper' & 'updateProdBasketToCheckEligibility' for TM2 callout 
    updateProdBasketToCheckEligibility: function (component, event, handler) {        
        var action2 = component.get(
            "c.updatetransitionBasketStagetoCheckEligibility"
        );
        action2.setParams({
            basketId: component.get("v.basketId")
        });
        action2.setCallback(this, function (response) {
            var basket = response.getReturnValue();
            console.log('basket@@@');
            console.log(basket);
            if (response.getState() == "SUCCESS" && basket != null) {
                component.set("v.ProdBasket", basket);                
                //component.set("v.ProdBasket.Transition_basket_stage__c", true);
            }
            component.set("v.loadingFixedSpinner", false);
        });
        $A.enqueueAction(action2);
    },
    
    getServicesHelper : function(component,event,helper){
        var basktID = component.get("v.basketId");
        var action = component.get("c.getTM2CallServices");
        action.setParams({ 
            "basketId": basktID 
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {   
                this.pollApex(component, event, helper);
            }
        });            
        $A.enqueueAction(action);
    },    
    //EDGE-218031: vivek
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
    
    refreshAction: function (component, event, helper) {
        var action = component.get("c.getBasket");
        var basketId = component.get("v.basketId");
        action.setParams({
            basketId: basketId
        });
        action.setCallback(this, function (response) {
            component.set("v.ProdBasket", response.getReturnValue());
            var productBasket = component.get("v.ProdBasket");
            //EDGE-227999 : Defect fix
            if(productBasket.Transition_basket_stage__c == "Reservation Completed"){
                component.set("v.isEnabled", true);
            }
           if(productBasket.Transition_basket_stage__c == "Reservation Completed" || productBasket.Transition_basket_stage__c == "Reserved with Errors" ){
                component.set("v.loadingFixedSpinner", false);
                component.set("v.showProgressRing", false);
                var checkOnLoad=false
                this.populateServiceNumbers(component, event, helper,checkOnLoad);
                
            }
            else if(productBasket.Transition_basket_stage__c == "Reservation Triggered"){
                window.setTimeout(
                    $A.getCallback(function() {
                    }), 20000
                );
                component.set("v.loadingFixedSpinner", false);
            }
            
        });
        $A.enqueueAction(action);
    },
    //EDGE-195766 Ends here
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
        console.log("in callapex");
        console.log("in currentdate: ",currentdate);
        let intervalId = "";
        var offerType=component.get("v.selectedTab");
        var action = component.get("c.getTramsErrorCode");
        var retVal ;
        action.setParams({ 
            "offerType":offerType,
            "basketId": component.get("v.basketId"),
            "exetype":"TM2",
            "currentDate":currentdate
        });
        action.setCallback(this, function(response) {
            //this.handleResponse(response, component);
            retVal = response.getReturnValue() ;
            component.set("v.errorWrap",retVal); 
            console.log("retVal: ",JSON.stringify(retVal));
            
            if(retVal!=null && retVal.executiontype!='Execution Error'){
                window.clearInterval(intervalId);
                this.updateProdBasketToCheckEligibility(component, event, helper);
            }
            else if(retVal!=null){
                window.clearInterval(intervalId);
                component.set("v.loadingSpinner",false);
                component.set("v.loadingFixedSpinner", false); 
				var checkOnLoad = false;  
                this.getTransitionBasketStatus(component, event, helper, checkOnLoad);
                this.showCustomToast(
                    component,
                    retVal.toastMessage,
                    "",
                    "error"
                );
            }
        });

        if(retVal==null){
            //if( retVal.tramasErrorcode!=null && retVal.tramasErrorcode!=''){
            intervalId =  window.setInterval(
                $A.getCallback(function() { 
                    $A.enqueueAction(action); 
                }), 10000
            );
            // }
        }
    },
    showCustomToast: function(cmp, message, title, type) {
        $A.createComponent(
            "c:customToast",
            {
                type: type,
                message: message,
                title: title
            },
            function(customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");                    
                    body.set("v.body", customComp);
                }
            }
        );
    },
    
    /* EDGE-203927 Starts */
    handlerTransRowSelected:function(component, event, helper){
        var selectedRowdata = JSON.parse(event.getParam('selectedRow'));
        component.set("v.selectedTransitionList",selectedRowdata);
        var selectedTransitionNumberList =[];
         if(selectedRowdata.length > 0){
            component.set("v.showAssignButton",true); 
            for(var j=0; j<selectedRowdata.length; j++ ){  
                if(selectedRowdata[j].tramasStatus != 'Completed' && component.get("v.showAssignButton")){
                    component.set("v.showAssignButton",false);
                    break;
                }
                selectedTransitionNumberList.push(selectedRowdata[j].Service_Id);
            }
        }
        else{
          component.set("v.showAssignButton",false);  
        }
        this.selectTransitionNumberEvt(component, event, helper,selectedTransitionNumberList);
    },
     //203932-Dheeraj Bhatt-pass legacy number for PC assignment 
    selectTransitionNumberEvt:function(component, event, helper,selectedTransitionNumberList){
        console.log('before event')
        var appEvent = $A.get("e.c:selectTransitionNumberEvt");
        appEvent.setParams({
            "selectedTransitionList" :component.get("v.selectedTransitionList"),
            "showAssignButton":component.get("v.showAssignButton"),
            "selectedTransitionNumberList":selectedTransitionNumberList
        });
        appEvent.fire();
    },
     //203932-Dheeraj Bhatt-Refresh Transition Screen on Assignment or un-Assignment of number from PC
    handleRefreshTransitionTableEvt:function(component, event, helper){
        var transitionList=component.get("v.transitionList");
        this.populateServiceNumbers(component, event, helper,true);
    } 
})