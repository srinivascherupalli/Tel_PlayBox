({
    navigateToBasket : function(component){
        var selectedSite = component.get("v.selectedSite");
        console.log(selectedSite);
        var action = component.get('c.redirectToBasket');
        action.setParams({"legacyProd" : selectedSite,"selectedOffer":JSON.stringify(component.get("v.selectedOffer")),"opportunityID": component.get('v.oppId')});
        action.setCallback(this, function(response) {
        var data = response.getReturnValue();
        // this data will be string url to which we have to navigate
                if (data != null && response.getState()) {
                    var urlToBasket = window.location.href;
                    var occ = urlToBasket.indexOf('#');
                    var actualURL = urlToBasket.substring(0, occ) + '#/sObject' + data;
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": actualURL
                    });
                    urlEvent.fire();
                } else {
                    this.showToast(component, 'Failure', "Please contact Administrator for help!");
                }
            });
            $A.enqueueAction(action);
    },   
    
    showToast: function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration: 2500,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
})