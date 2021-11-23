({
	doInit : function(component, event, helper) {
        
        component.set("v.paramname", 'agid');
        
        var agrId = helper.splitURLparams(component);
        
        component.set("v.agreementId", agrId);
        var aid=component.get("v.agreementId");
        
        helper.getAgreementSchedules(component, event, helper);
	}
})