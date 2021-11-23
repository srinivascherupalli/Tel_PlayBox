({
	doInit : function(component, event, helper) {
         component.set("v.columns", helper.getColumnDefinitions());
        var solId=component.get("v.solutionId");
        console.log('solId------>',solId);
            var action = component.get("c.getSubscriptionDetails");
    action.setParams({
      solutionId : solId
    });
    action.setCallback(this, function(response) {
     	  var state = response.getState();
        var res = response.getReturnValue();
        res.forEach(function (res) {
                        var url='';
                   		url=JSON.stringify(window.location.href);
                   	   if(url.includes('/partners/')){ //EDGE-180234
                      	  res.subscriptionNameLink = '/partners/' + res.SubscriptionID;
                       		if (res.SiteID != null) {
                                res.siteAddressLink = '/partners/' + res.SiteID;
                            }
                        }
            		else{
                         res.subscriptionNameLink = '/' + res.SubscriptionID;
                            if (res.SiteID != null) {
                                res.siteAddressLink = '/' + res.SiteID;
                            }
                    	}
                        });
        component.set("v.filteredData", res);
        console.log('res---->',res);
       
    });
    $A.enqueueAction(action);
    },
    
    openModel: function(component, event, helper) {
    // for Display Model,set the "isOpen" attribute to "true"
    component.set("v.isOpen", true);
   
  },
    
     closeModel: function(component, event, helper) {
         //accid=component.get('v.accountID');

    component.set("v.isOpen", false);
  }
})