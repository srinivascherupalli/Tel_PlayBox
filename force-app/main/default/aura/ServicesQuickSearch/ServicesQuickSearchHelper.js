({
  getServices: function(component) {
    var spinner = component.find('spinner');
    $A.util.removeClass(spinner, "slds-hide");
           
    var searchTerm = component.find("searchTerm").get("v.value");
    if (searchTerm != null) {
    	var action = component.get("c.getServices");
    	action.setParams({
            "searchTerm": searchTerm
        });
    
    	action.setCallback(this, function(response) {
        	this.doLayout(response, component);
    	});
    	$A.enqueueAction(action);
    }
  },
    doLayout: function(response, component) {
        //var spinner = component.find('spinner');
        //$A.util.addClass(spinner, "slds-hide");
        var warning = component.find('warning');
        if (response.getReturnValue() != null)
        {
            var data = JSON.parse(response.getReturnValue());
            if (data.error) {
                console.log("Error");
                component.set("v.errorMessage", data.error);            
                $A.util.removeClass(warning, 'slds-hide');
            } else {
                $A.util.addClass(warning, 'slds-hide');
            }
            component.set("v.servicesList", data);
            console.log("the Data: ", data);
        }
        else {
            console.log("Error");
            component.set("v.errorMessage", 'No results found.');            
            $A.util.removeClass(warning, 'slds-hide');
        }
    }
})