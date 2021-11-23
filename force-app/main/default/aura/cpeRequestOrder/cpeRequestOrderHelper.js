({	
    acceptQuotes: function(component, event, helper){
        
        var selectedRecId = component.get("v.noOfCLISelected");
        if(selectedRecId == null || selectedRecId.length =='0' ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : "Error!",            
                "message": "Please specify the quote which you'd like to order",
                "type": "error",
                "duration":" 4000"
            });
            toastEvent.fire();
            component.set('v.showSpinner',false);
            return;
        }
        var action = component.get("c.acceptQuotes");
        action.setParams({quoteList : component.get('v.noOfCLISelected'), caseId : component.get('v.caseId')});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.quoteDeatils", response.getReturnValue());
                var quoteDetails = response.getReturnValue();
                var selectedRowsIds = [];
                var noOfSelectedRowsIds = [];
                var count = 0;
                for (var i = 0; i < quoteDetails.length; i++) {
                    if(quoteDetails[i].cpe_Accept_Quote__c){
                        //selectedRowsIds[count] = quoteDetails[i].Id;
                        selectedRowsIds.push({'Id' :quoteDetails[i].Id, 'cpe_Requote_Details__c': quoteDetails[i].cpe_Requote_Details__c, 'cpe_Accept_Quote__c': quoteDetails[i].cpe_Accept_Quote__c});
                        noOfSelectedRowsIds[count] = (quoteDetails[i]);
                        count++;
                    }

                } 
                component.set("v.noOfCLISelected",noOfSelectedRowsIds);
                component.set('v.isOnLoad',false);
                component.set('v.showFieldsScreen',true);
            }
            else if (state === "ERROR") {
                component.set('v.showSpinner', false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "Error!",            
                            "message": errors[0].message,
                            "type": "error",
                            "duration":" 4000"
                        });
                        toastEvent.fire();
                    }
                } 
            }
        });
        $A.enqueueAction(action);
    },

    attachDocument: function(component, event, helper){
        var action = component.get("c.attachDocumentToOpportunity");
        action.setParams({quoteList : component.get('v.noOfCLISelected'), caseId : component.get('v.caseId')});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
            }
            else if (state === "ERROR") {
                component.set('v.showSpinner', false);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "Error!",            
                            "message": errors[0].message,
                            "type": "error",
                            "duration":" 4000"
                        });
                        toastEvent.fire();
                    }
                } 
            }
        });
        $A.enqueueAction(action);
    },
    
    showFileUploadMsg: function(component, event, helper) {
        const isShippingAus = component.get('v.caseRecord.cpe_Is_Shipping_Outside_Of_Australia__c');
        const noOfServices = component.get('v.caseRecord.salesup_No_of_sites_or_services__c');
        return noOfServices > 1 || 
               isShippingAus === 'Yes';
    },
})