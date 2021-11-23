({
    navTo : function(cmp, event, helper) {
        var url = event.currentTarget.dataset.url;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    }
})