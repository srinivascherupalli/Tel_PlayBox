({
	showCustomToast: function (cmp, message, title, type) {
		$A.createComponent(
			"c:customToast", {
				"type": type,
				"message": message,
				"title": title
			},
			function (customComp, status, error) {
				if (status === "SUCCESS") {
					var body = cmp.find("container");
					body.set("v.body", customComp);
				}
			}
		);
	},

	 //Added by vivek as a part of EDGE -206232 || Start
	 fireTenancyEvent: function (component, event, helper , guId) {
		 console.log('guId --> ' , guId );
        var myEvent = $A.get("e.c:CustomerExistingTenancyEvent");
        myEvent.setParams({
            "selectedTenancyIds":component.get("v.selectedTenancyIds"),
			"actualTenancyId" : guId,
			"callerName" : component.get('v.callerName')
        });
        console.log('firing event from component vivek controller' , myEvent);
        myEvent.fire();
    }
    //Added by vivek as a part of EDGE -206232 || Start
})