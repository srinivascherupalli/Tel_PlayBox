({
    doInit : function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        //var basketId = component.get("v.basketIDURL");
        var basketId = window.location.href.split("=")[1].substring(0, 18);
        component.set("v.basketId", basketId);
        var action = component.get("c.fetchSiteFromBasketControllerMap");
        action.setParams({"basketId" : basketId});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data!=null){
                component.set("v.siteDTOMap", data);
                var childCmp = component.find("GetSiteComp")
                childCmp.displaySites();
                helper.getBasket(component);
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
    
    
})