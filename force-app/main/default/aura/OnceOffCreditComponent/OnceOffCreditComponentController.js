({
    
    handleSubmit:function(component, event, helper) {     
        event.preventDefault(); // stop form submission
        helper.handleSubmit(component, event);
        },
    /* EDGE-158381: ConfirmDialog Yes */
     handleConfirmDialogYes : function(component, event, helper) {
         component.set('v.showConfirmDialog', false);
         helper.handleSubmitData(component, event, helper);
         
    },
     /* EDGE-158381: ConfirmDialog No */
    handleConfirmDialogNo : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },
    
     /*  EDGE-149630: Fetch Billing Account Predebt or not for a billing account*/
    checkPredebtBAN : function(component, event, helper) {
        if (component.get("v.CreditObj.Billing_Account_Number_BAN__c") != '' && component.get("v.CreditObj.Billing_Account_Number_BAN__c") != 'MALFORMED_ID') 
        {
             helper.checkPredebtBANHelper(component, event, helper);
        }
        else  {
            component.set("v.preDebt",false);
        }
	},
    
    /*  EDGE-149630: Fetch Billing Account Predebt or not for a billing account*/
    checkSelectedProduct : function(component, event, helper) {
        if (component.get("v.CreditObj.Non_Marketable_Product__c") != '' && component.get("v.CreditObj.Non_Marketable_Product__c") != 'MALFORMED_ID') {
            helper.checkSelectedProductHelper(component, event, helper);
        }
        else   {
            component.set("v.isPredebt",false);
            
            //DPG-3598 Start
            var opts = [];
            component.find("reasonCodeField").set("v.options", opts);
            component.set("v.disableReasonCode", false);
            //DPG-3598 End.
        }
    }
})