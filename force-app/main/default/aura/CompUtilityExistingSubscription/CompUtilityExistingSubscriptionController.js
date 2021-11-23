({
	    getExistSub : function(component, event, helper) {
		document.getElementById("ExistSubCmp").style.display = "block";
        var oldConfigId = component.get("v.oldConfigId");
        if(oldConfigId)
        {
            var action = component.get('c.getExistingSubscription');
        action.setParams({
            "configId": oldConfigId
        });
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set('v.existingSubscriptions', data);
            component.set('v.isMac', true);
            //var extCmp = document.querySelectorAll('.display-none-cmp');
            //extCmp.classList.remove('display-none-cmp');
        });
        $A.enqueueAction(action);
        }
            else
            {
                component.set('v.isMac', false);
            }
    },
    displayNone : function(component, event, helper) {
		//document.getElementById("ExistSubCmp").style.display = "none";
		var toggleDiv = component.find("ExistSubCmp");
        $A.util.toggleClass(toggleDiv, "display-none-data");


	},
})