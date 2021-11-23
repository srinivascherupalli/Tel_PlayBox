({
    updateDPR: function(component, event) {
        var frameAgreementId = component.get("v.FrameId");
        var action = component.get("c.insertContJuncFA");
        var agreementDecision = component.get('v.AgreementDecision');
        action.setParams({ "frameAgreementId":frameAgreementId,
                           "agreementDecision":agreementDecision });
        component.set("v.showSpinner",true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.DPRId", response.getReturnValue().Related_Deal__c);
                component.set("v.ContractJunctionID", response.getReturnValue().Id);
                var test1 = component.get("v.ContractJunctionID");
                var test = component.get("v.DPRId");
                component.set("v.showSpinner",false);
            } else {
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    //To get ContractSupport case RecordType
    //EDGE:123784 | Generate the pricing contract after the deal has been approved.
    fetchContractSupportRecordType: function(component, event, helper) {
        // debugger;
        var action = component.get("c.getContractSupportCaseRecordType");
        action.setCallback(this, function(response) {
            //debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set(
                    "v.caseContractSupportRecordType",
                    response.getReturnValue()
                );
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    caseAgreementval: function(component, event, helper) {
        // debugger;
        var delegatedpricingreqId = component.get("v.DPRId");
        if(delegatedpricingreqId!="" && delegatedpricingreqId!=null){
            var resolveSAType = component.get("c.resolveSAType");
            resolveSAType.setParams({
                "DPRId":delegatedpricingreqId
            });
            resolveSAType.setCallback(this, function(response) {
                var state = response.getState();  
                if(component.isValid() && state === "SUCCESS") {
                    var res=response.getReturnValue();
                    component.set("v.AgreementDecision", response.getReturnValue());	
                    component.set("v.isAgreementCheckCompleted",true);
                }
                else if(state === "ERROR"){
                    component.set("v.errorMsg", 'Something went wrong.');
                    helper.showError(component, event, helper);
                }				
                
            });
            $A.enqueueAction(resolveSAType);	
        }     
    },
    
    insertContractJunctionForCase: function(component, event, helper) {
        // debugger;
        var frameAgreementId = component.get("v.FrameId");
        var action = component.get("c.insertContJuncFA");
        action.setParams({frameAgreementId: frameAgreementId });
        console.log("est"+frameAgreementId);
        action.setCallback(this, function(response) {
            debugger;
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ContractJunctionID", response.getReturnValue().Id);
                console.log("est"+ContractJunctionID);
                this.updateDPR(component);
            } else if (state === "INCOMPLETE") {
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    getVfOrigin : function(component){
        var vfOrigin = $A.get("$Label.c.FAPostURL");
        var profiles = "PRM Admin - Australia,PRM Community User - Australia";
        var profileList = profiles.split(",");
        profileList.forEach(function(item,index){
            if(component.get('v.CurrentUser')['Profile'].Name == item){
                vfOrigin = $A.get("$Label.c.FAPartnerPostURL");
            }
        });
        return vfOrigin;
    }
});