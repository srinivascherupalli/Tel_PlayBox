({
    /*----------------------------------------------------------------------
	EDGE-147537
    Method-billingAccountDetails
    Description:To retrive the billing account details from BDS
    Author:Aishwarya
    ----------------------------------------------------------------------------*/
    billingAccountDetails: function(component){

        component.set("v.loadingSpinner",true);

        var action = component.get("c.fetchBillingAccountNumberFromBDS");
        action.setParams({
            'ban': component.get("v.billingRecord.Billing_Account_Number__c")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var billingDetails = JSON.parse(response.getReturnValue());
                if(billingDetails != null &&(billingDetails.code != 201 && billingDetails.code != 200) && billingDetails.errors.length > 0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:billingDetails.errors[0].message,
                        messageTemplate: 'Mode is pester, duration is 5sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'error'
                    });
                    toastEvent.fire();

                    component.set("v.loadingSpinner",false);
                } 
                else if(billingDetails!=null)
                {
                    component.set("v.BillingAcc", billingDetails.billingAccount);
                    this.doInit(component,event);
					var writeOffP2O = component.get("v.billingRecord.Written_Off__c");
                    var writtenOff;
					//EDGE-151581. Show Written off as true if written_off__c flag is true
					if( writeOffP2O ){
                        writtenOff=true;
                    }
                    else{
						writtenOff=billingDetails.billingAccount.writtenOffStatus=='WriteOff'?true:false;
					} 
                    component.set("v.BillingAcc.writtenOffStatus", writtenOff);
                   component.set("v.loadingSpinner",false);

                }
            } else if (state==="ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Error occured while parsing the request',
                    key: 'info_alt',
                    type: 'error'                
                });
                toastEvent.fire();

                component.set("v.loadingSpinner",false);

            }
        }); 
        $A.enqueueAction(action);  
    },

    doInit : function(component,event){
        var action = component.get("c.getWriteoffApprovalDisplay");
        var billingAccId = component.get("v.recordId");
        console.log('billingAccId: ',billingAccId);
        action.setParams({
            'billingAccId': billingAccId
        });   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log('resp:getWriteoffApprovalDisplay',resp);
                component.set("v.isApprovalBtnDisabled",resp.isApprovalBtnDisabled);
                 component.set("v.isApprovalBtnShown",resp.isApprovalBtnShown);
            } 
        });
        $A.enqueueAction(action);
    },
    handleApprovalProcessInitiation : function(component,event){
        var action = component.get("c.initiateApprovalProcess");
        var billingAccId = component.get("v.recordId");
        component.set("v.isApprovalBtnDisabled",true);
        console.log('billingAccId: ',billingAccId);
        component.set("v.loadingSpinner",true);
        action.setParams({
            'billAccid': billingAccId
        });   
        action.setCallback(this, function(response) {
            var state = response.getState();
             console.log("state: ",state);
            if (state === "SUCCESS") {
                var resp = response.getReturnValue();
                console.log("resp: handleApprovalProcessInitiation",resp);
                if(resp==true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message:'Approval Process initiated successfully.',
                        messageTemplate: 'Mode is pester, duration is 5sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'success'
                    });
                    toastEvent.fire();
                    component.set("v.loadingSpinner",false);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message:'Error in initiating approval process.',
                        messageTemplate: 'Mode is pester, duration is 5sec and Message is overrriden',
                        key: 'info_alt',
                        type: 'error'
                    });
                    toastEvent.fire();
                    component.set("v.loadingSpinner",false);
                }
            } 
        });
        $A.enqueueAction(action);
    }

})