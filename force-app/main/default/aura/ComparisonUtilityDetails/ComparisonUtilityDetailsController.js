({
    displayGetService : function(component, event, helper) {
        helper.removeClass(component, event, helper);
        helper.addClass(component, event, helper);
        var compEvent = component.getEvent("getTabName");
        compEvent.setParams({
            "tabName" : "GetService" 
        });
        compEvent.fire();
        if(component.get("v.adborid"))
        {
            var childCmpGetService = component.find("GetServiceComp");
            childCmpGetService.getGetLegacyServices();
            var childCmpExistSub = component.find("GetExistingSubscription");
            childCmpExistSub.displayNone();
        }
    },
    displayExistSub : function(component, event, helper) {
        helper.removeClass(component, event, helper);
        helper.addClass(component, event, helper);
        var compEvent = component.getEvent("getTabName");
        compEvent.setParams({
            "tabName" : "ExistingSubscription" 
        });
        compEvent.fire();
        if(component.get("v.adborid"))
        {
            var childCmpExistSub = component.find("GetExistingSubscription");
            childCmpExistSub.getExistSub();
            var childCmpGetService = component.find("GetServiceComp");
            childCmpGetService.displayNone();
        }
    },
    handleGetServicesEvent	: function(component,event,helper){
        helper.removeClass(component, event, helper);
        var childCmpGetService = component.find("GetServiceComp");
        childCmpGetService.displayNone();
        var childCmpExistSub = component.find("GetExistingSubscription");
        childCmpExistSub.displayNone();
        component.set("v.oldConfigId", event.getParam("oldConfigId"));
        component.set("v.adborid", event.getParam("adborid"));
        component.set('v.siteName',event.getParam("siteName"));
    },
    
})