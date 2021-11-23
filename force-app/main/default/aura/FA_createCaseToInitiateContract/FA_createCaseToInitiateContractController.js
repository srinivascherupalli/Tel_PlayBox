({
    doInit: function(component, event, helper) {
        var recordId = component.get("v.FrameId");
        console.log(recordId);
        component.set("v.FrameId", recordId);
        var oppId = component.get("v.OpportunityId");
        console.log(oppId);
        component.set("v.OpportunityId", oppId);
        helper.fetchContractSupportRecordType(component, event);
		helper.caseAgreementval(component,event);   // DIGI-24743
        //helper.updateDPR(component,event);
        
        
    },
    
    //EDGE:123784 | Generate the pricing contract after the deal has been approved.
    initiateContractHandleSubmit: function(component, event, helper) {
        event.preventDefault();
        const ICfields = event.getParam("fields");
        if(ICfields.Description.length > 50 ){
            component.set("v.showSpinner",true);
            var record = event.getParam("record");
            ICfields.Subject = "Pricing Contract";
            ICfields.Status = "New";
            ICfields.OpportunityId__c = component.get("v.OpportunityId");
            ICfields.FrameAgreement__c = component.get("v.FrameId");
            //ICfields.soc_Request_Type__c = "Contract Support";
            console.log("test" + component.get("v.DPRId"));
            ICfields.Deal__c = component.get("v.DPRId"); //EDGE:136226
            console.log(ICfields.Deal__c);
            ICfields.ContractJunction__c = component.get("v.ContractJunctionID");
            console.log(ICfields.ContractJunction__c); //EDGE:136226
            var MarkasVariation = component.get("v.DprName.Mark_as_Variation__c");
            if (MarkasVariation == true) {
                ICfields.Reason = "Contract Variation";
            } else {
                ICfields.Reason = "New Contract";
            }
            component.find("myRecordForm").submit(ICfields);
        }
        else {
            var state = 'WARNING'
            console.log('inside handleSubmit ELSE');
            var message = {
                'displayMsg':'Please ensure that the Description field has more than 50 characters',
                'type' : state
            }
            var vfOrigin = helper.getVfOrigin(component);
            window.postMessage(message, vfOrigin); 
        }
    },
    
    //EDGE:123784 | Generate the pricing contract after the deal has been approved..
    initiateContractHandleSuccess: function(component, event, helper) {
        helper.updateDPR(component);
        var message = {
            'displayMsg':'Case is created Successfully!!',
            'type' : 'SUCCESS'
        }
        component.set("v.Status",true);
        var vfOrigin = helper.getVfOrigin(component);
        window.postMessage(message, vfOrigin);
    },
    
    //EDGE:123784 | Generate the pricing contract after the deal has been approved.
    initiateContractonCancel: function(component, event, helper) {},
    
    //EDGE:123784 | Generate the pricing contract after the deal has been approved.                                initiateContractHandleSuccess : function(component, event, helper) {
    initiateContracthandleError: function(component, event, helper) {}
});