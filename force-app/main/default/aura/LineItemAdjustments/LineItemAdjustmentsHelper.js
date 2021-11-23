/* **************************************************************************
EDGE        -88294
component   -LineItemAdjustmentsHelper
Description -Helper for LineItemAdjustmentsComponent 
Author      -Dheeraj Bhatt
********************************************************************************* */

/* Getting the CreditAndAdjustment record*/
({
    doInit:function(component,event,helper) {
        var action = component.get("c.getCreditAndAdjustment");
        action.setParams({"id": component.get("v.recordId"),});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.CreditAndAdjustment",response.getReturnValue());
                component.set("v.recordIdNew",component.get("v.CreditAndAdjustment.Case_Number__c"));
                this.getLatestCredit(component, event, helper);
            } 
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
        });
        
        $A.enqueueAction(action);
    },
    
    getLatestCredit: function(component, event, helper){
        var action = component.get("c.getCreditAndAdjustmentRecord");
        action.setParams({"id": component.get("v.recordIdNew"),});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.NewCreditAndAdjustment",response.getReturnValue());
                console.log("Case: "+JSON.stringify(component.get("v.NewCreditAndAdjustment")));
                this.submit(component, event, helper);
            } 
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
        });
        
        $A.enqueueAction(action);
    },
    /* For submitting Sending Line Item Adjustments request to BDS */
    submit: function(component, event, helper) {
        console.log("Test:" +component.get("v.NewCreditAndAdjustment.Id"));
        var newCreditId = component.get("v.NewCreditAndAdjustment.Id");
        //EDGE-171597 -------START-----
        if(component.get("v.NewCreditAndAdjustment.Id")!=component.get("v.CreditAndAdjustment.Id")){
            component.set("v.message",$A.get("$Label.c.Recent_CA_Modal"));
        }
        else if(component.get("v.CreditAndAdjustment.Case_Number__r.Status") != "Resolved"){
            component.set("v.message",$A.get("$Label.c.Not_Resolved_CA_Modal"));
        }
        //EDGE-171597 -------END-----
            else if(component.get("v.CreditAndAdjustment.Determination_Status__c") != 'Approved'){
                component.set("v.message",$A.get("$Label.c.Credit_and_Adjustment_Not_Approved"));
            }
                else if(component.get("v.CreditAndAdjustment.Submitted__c") == true){
                    component.set("v.message",$A.get("$Label.c.Submit_To_BDS_Error_Message"));
                }
                    else if(component.get("v.CreditAndAdjustment.Determination_Status__c") == 'Approved' && component.get("v.CreditAndAdjustment.Accepted_by_Customer__c") != true){
                        component.set("v.message",$A.get("$Label.c.Submit_To_BDS_Confirm_Message"));
                        component.set("v.showbutton",true)
                    }
                        else if(component.get("v.CreditAndAdjustment.Determination_Status__c") == 'Approved' && component.get("v.CreditAndAdjustment.Accepted_by_Customer__c") == true && component.get("v.CreditAndAdjustment.Submitted__c") != true){
                            this.helperSubmit(component,event,helper);                  
                        }
    },
    
    /*helper method for submitting request to BDS */
    helperSubmit : function(component,event,helper) {
        var action = component.get("c.doSubmit");
        action.setParams({"creditAndAdjustmentId":component.get("v.recordId"),
                          "handler":component.get("v.handler")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.type",'confirm')
                component.set("v.message",response.getReturnValue())
                component.set("v.showbutton",false)
                setTimeout(function(){
                    $A.get('e.force:closeQuickAction').fire();
                }, 2000);
                $A.get('e.force:refreshView').fire();
            } 
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
        });
        $A.enqueueAction(action); 
    },
})