({
    navHome : function(cmp, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "https://www.telstra.com.au/business-enterprise/self-service/telstra-connect"
        });
        urlEvent.fire();
    }
})