({
    doInit : function(component, event, helper) {
        alert('new comp');
        component.set("v.loadingSpinner", true);
        //var basketId = component.get("v.basketIDURL");
        var basketId = window.location.href.split("=")[1].substring(0, 18);
        component.set("v.basketId", basketId);
        var action = component.get("c.fetchSiteFromBasketControllerMap");
        action.setParams({"basketId" : basketId});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(response.getState()=='SUCCESS' && data!=null){
                component.set("v.siteDTOMap", data);
                var childCmp = component.find("GetSiteComp");
                childCmp.displaySites();
                helper.getBasket(component);
                var storeJSON = component.get("v.storedJSON");
                //if(!storeJSON){
                //helper.storeJSONdata(component);
                
                //}    
            }
        });
        $A.enqueueAction(action);
        
    },
    handleGetSelectedProduct : function(component, event, helper) {
        var selectedProduct = event.getParam("selectedProduct");
        if(selectedProduct !=null  && selectedProduct !="")
        {
            component.set("v.selectedProdFinal", selectedProduct);
            helper.selectedDTO(component, event, helper);
        }
        else{
            helper.navigateToRollCall(component, event, helper);
        }
    },
    handleGetSelectedProduct_V2 : function(component, event, helper) {
        var selectedProduct = event.getParam("selectedProduct");
        if(selectedProduct !=null  && selectedProduct !="")
        {
            component.set("v.selectedProdFinal_V2", selectedProduct);
            helper.selectedDTO_V2(component, event, helper);
        }
        else{
            helper.navigateToRollCall(component, event, helper);
        }
    },
    processTransition : function(component, event, helper) {
        var callSelectedProduct = $A.get("e.c:CallGetSelectedProduct");
        callSelectedProduct.fire();
    },
    cancelTransition : function(component, event, helper) {
        helper.navigateToRollCall(component, event, helper);
    },
    handleSaveButtonOnTabClick : function(component, event, helper) {
        var tabName = event.getParam("tabName");
        if(tabName == "GetService")
        {
            component.set("v.displayTransBtn",true);
        }
        else if(tabName == "ExistingSubscription")
        {
            component.set("v.displayTransBtn",false);
        }
    },
   
    gotoAccount: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.ProdBasket.csbb__Account__c")
        });
        navEvt.fire();
    },
    gotoOpportunity: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.ProdBasket.cscfga__Opportunity__c")
        });
        navEvt.fire();
    },
    gotoUser: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.ProdBasket.CreatedById")
        });
        navEvt.fire();
    },
    
   
})