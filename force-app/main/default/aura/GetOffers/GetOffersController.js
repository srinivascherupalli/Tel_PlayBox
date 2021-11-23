({
    doInit : function(component, event, helper) {
        //get loading spinner before data gets loaded
        component.set("v.loadingSpinner", true);
        setTimeout(function(){
            component.set("v.loadingSpinner", false);
       }, 2000);
       //helper.getOffers(component);
	}, 
    
    
	 onSelectOffer: function(component, event, helper){
        component.find("generateBasket").set("v.disabled",false);
        var id_str = event.currentTarget.dataset.value;
        component.set('v.selectedOffer',id_str);
	},
    
    navigateToGetServices : function(component, event, helper) {
    var siteName = component.get("v.siteName");
    var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:GetServices",
            componentAttributes: {
                    siteName : siteName
                }
        });
    	evt.fire();    
	},
    
    navigateToAccountPage : function(component, event, helper) {
    	var url = window.location.href;
    	var nextURL;
    	var orgURL = $A.get("$Label.c.Lightning_Org_URL");
    	nextURL = orgURL.split('#/n')[0] + '?source=aloha#';
    	window.location = nextURL;    
	},
    
     onGenerateBasket: function(component, event, helper){
        console.log("in controller");     
        helper.navigateToBasket(component);
	}
})