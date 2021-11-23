({
	doInit : function(cmp) {
        var action = cmp.get("c.getSubscriptionValue");
        action.setParams({ recordId : cmp.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(JSON.stringify( response.getReturnValue() ));
                let objRec = response.getReturnValue();
                //cmp.set("v.wrapObj", objRec);
                cmp.set("v.subsValue", objRec.csordtelcoa__Subscription_Number__c);
                let url = '/'+objRec.Id;
                cmp.set("v.link", url);
            }
            else if (state === "INCOMPLETE") {
                console.log('Incompelte');
            }
            else if (state === "ERROR") {
                var errors = response.getError();                       
                cmp.set("v.showErrors",true);
                cmp.set("v.errorMessage",errors[0].message);
            }
        });
        $A.enqueueAction(action);
	},
    
    /*gotoRecord : function(cmp){
        let rec =cmp.get("v.subsRec");
        let navEvt = $A.get("e.force:navigateToSObject");
    		navEvt.setParams({
      		"recordId": rec.Id,
      		"slideDevName": "detail"
    	});
    	navEvt.fire();
    }*/
})