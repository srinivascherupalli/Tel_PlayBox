({
    validateData : function(component, event, helper) {
        debugger;
        var action = component.get("c.getCaseValues");
        var caseId = component.get("v.recordId");
        var contextVar = component.get("v.contextVar");
        action.setParams({
            
            "caseId": caseId,
            "contextVar": contextVar
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            debugger;
            if(state === "SUCCESS") {
                var errorMsg = response.getReturnValue();
                component.set("v.errorMessage",errorMsg);
                if(errorMsg == "Bid"){
                    component.set("v.showComp",false);
                }
                if(errorMsg == "modifySolButton"){
                    component.set("v.showComp",false);
                    component.set("v.showComp1",true);
                }
                //Boolean check to check if the call is from init or Button Click
                //Ignore below code on for page Load/Init
                //Execute if called from button click, to check record changes after page Load
                if(!component.get("v.onLoad") && contextVar != "onClickModifySol" ){
                    debugger;
                    var bidSuccessMsg = $A.get("{!$Label.c.cusdl_Bid_record_success}");
                    var reqFieldErrorMsg = $A.get("{!$Label.c.cusdl_Required_field_message}");
                    var errorMsg = component.get("v.errorMessage");
                    //Set flow variables
                    if(errorMsg == bidSuccessMsg){
                        component.set("v.dataValidate",true);
                        var flow = component.find("flowData");
                        var recId = component.get("v.recordId");
                        var inputVar =[
                            {
                                name : "recordId",
                                type : "String",
                                value : recId
                            }
                        ];
                        //Call Flow and set the input variables
                        debugger;
                        flow.startFlow("cusdl_create_ORB_Approval", inputVar);
                        component.set("v.spinner",true);
                    }
                    if(errorMsg == reqFieldErrorMsg){
                        component.set("v.dataValidate",false);
                        debugger;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "Error:",            
                            "message": errorMsg,
                            "type": "error",
                            "duration":" 7000"
                        });
                        toastEvent.fire();
                    }
                }
                else if(contextVar == "onClickModifySol"){
                    debugger;
                    var reqFieldErrorMsg = $A.get("{!$Label.c.cusdl_Required_field_message}");
                    console.log('!!!'+reqFieldErrorMsg);
                    var errorMsg = component.get("v.errorMessage");
                    component.set("v.spinner",false);
                    if(errorMsg == reqFieldErrorMsg){
                        component.set("v.dataValidate",false);
                        debugger;
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "Error:",            
                            "message": "Please fill all required fields before raising a Modify Solution request",
                            "type": "error",
                            "duration":" 7000"
                        });
                        toastEvent.fire();
                    }
                    else if(errorMsg == "modifySolButton"){
                        //component.set("v.dataValidate",false);
                        debugger;
                        component.set("v.spinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title" : "Success:",            
                            "message": "Case line Item record successfully created",
                            "type": "success",
                            "duration":" 7000"
                        });
                        toastEvent.fire();
                    }
                }
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title" : "Error:",            
                    "message": "Please try again later",
                    "type": "error",
                    "duration":" 7000"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})