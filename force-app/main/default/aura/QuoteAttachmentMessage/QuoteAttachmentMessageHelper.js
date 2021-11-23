({
    getQuoteStatus : function(component) {
        if(component.get("v.displayError") != 'Success'){
            var action = component.get("c.displayError");
            if(action!=undefined)
            { 
                component.set("v.ShowSpinner",true);
                action.setParams({ recordId : component.get("v.recordId") });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.displayError",response.getReturnValue());
                        if (response.getReturnValue() == 'Success')
                        {
                            component.set("v.ShowSpinner",false);
                            $A.get('e.force:refreshView').fire();
                            console.log("Success response");
                        }   
                    }
                    else if (state === "INCOMPLETE") {
                        console.log("Processing...");
                        component.set("v.ShowSpinner",false);
                    }
                        else if (state === "ERROR") {
                            component.set("v.ShowSpinner",false);
                            var errors = response.getError();
                            if (errors) {
                                if (errors[0] && errors[0].message) {
                                    console.log("Error message: " + 
                                                errors[0].message);
                                    console.log("v.ShowSpinner" + 
                                                component.get("v.ShowSpinner"));
                                }
                            } else {
                                console.log("Unknown error");
                            }
                        }
                });
                $A.enqueueAction(action);
            }
        }
    },
    getMessageOnStatus: function(component, event, helper, stateMsg) {
        var labelString = $A.get("$Label.c.Quote_AttachmentMsg_Success");
        var action = component.get("c.getQuoteStatus");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();  
            if(component.isValid() && state === "SUCCESS") {
                var qStatus = response.getReturnValue().Status;
               // alert(JSON.stringify(response.getReturnValue()) + '---->'+qStatus);
                var keyVal = ''
                if(qStatus == 'Generated'){
                    keyVal = 'QG';
                    component.set("v.quoteInfoHeader",'Success');
                }
                else if(qStatus == 'Presented'){
                    keyVal = 'QP';
                    component.set("v.quoteInfoHeader",'');
                }
                    else if(qStatus == 'Customer Validated'){
                        keyVal = 'CV';
                        component.set("v.quoteInfoHeader",'');
                    }
                        else if(qStatus == 'Void'){
                            keyVal = 'QV';
                            component.set("v.quoteInfoHeader",'');
                        }
                            else if(qStatus == 'Expired'){
                                keyVal = 'QE';
                                component.set("v.quoteInfoHeader",'');
                            }
                                else {
                                    keyVal = 'QI'; 
                                    component.set("v.quoteInfoHeader",'');
                                }
                var statusMsg = labelString.substring(labelString.lastIndexOf('['+keyVal+']') + 4, labelString.lastIndexOf("["+keyVal+"e]"));
                component.set('v.quoteStatusMsg',statusMsg);  
                
            }
            else if(state === "ERROR"){
                
            }
        });
        $A.enqueueAction(action); 
    }
})