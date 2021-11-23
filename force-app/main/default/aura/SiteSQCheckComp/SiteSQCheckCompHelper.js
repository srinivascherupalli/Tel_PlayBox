({
    /*******************************
    EDGE-119161
    Author:Ila 
    **********************************/
   /*******************************
    DIGI-2540
    Author -Ajith Kumar 
    Description- code changes to log auraException
    **********************************/
    fetchsqList: function(component, event, helper){
        var recordId = component.get("v.recordId");
        var action= component.get("c.getLatestSq");
        if(recordId!=null){
            action.setParams({"siteId": recordId});
        }
        action.setCallback(this, function(response) {
        var state = response.getState();            
        if(state === "SUCCESS") {
            var sqWrapList = response.getReturnValue();
            component.set("v.sqList", sqWrapList);
        }
        else if(state==="ERROR"){
        var errormsg= response.getError();
            if(errormsg){
                if(errormsg[0] && errormsg[0].message){
                    var logException=  component.get("c.logException");
                    logException.setParams({"error":errormsg[0].message,"methodName":"getLatestSq"});
                    logException.setCallback(this, function(response){
        });
        $A.enqueueAction(logException); 
        }
        }
        }
        });
        $A.enqueueAction(action);        
    },
        
    showCustomToast: function (cmp, message, title, type) {		
        $A.createComponent(
            "c:customToast", {
                "type": type,
                duration : 20800,
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
    /*******************************
    DIGI-2540
    Author -Ajith Kumar 
    Description- code Refactoring changes
    **********************************/
    checkSq : function(component, event, helper) {
        component.set("v.loadingSpinner", true); 
        //EDGE-128858 Defect fix for disabling check button
        component.set("v.isenabled",false);
        var action = component.get("c.triggerSQCheck");
        action.setParams({
            "addressId" : component.get("v.siteRecord.AdborID__c"),
            "siteId" : component.get("v.siteRecord.Id"),
            "tech": component.get("v.technologyType")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
                if (state === "SUCCESS") {
    /*******************************
    EDGE-119161/98319
    Author:Ila / Aishwarya
    **********************************/	
                    if(response.getReturnValue() === 'success'){
                        component.set("v.loadingSpinner",false); 
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            //EDGE-94105 Changed the message text
                            "title": "Success!",
                            "message": $A.get("$Label.c.SQ_Success"),
                            "type":"success"
                        });					
                        this.fetchsqList(component, event, helper);
                    }
                
                    else{
                        component.set("v.loadingSpinner",false);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            //EDGE-94105 Changed the message text
                            "title": "Error!",
                            "message": $A.get("$Label.c.SQ_Error"),
                            "type":"error"
                        });                    
                    }
                    toastEvent.fire(); 
                }
                else if (state === "INCOMPLETE") {
                    component.set("v.loadingSpinner",false);                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        //EDGE-94105 Changed the message text
                        "title": "Error!",
                        "message": $A.get("$Label.c.SQ_Error"),
                        "type":"error"
                    });   
                    toastEvent.fire();
                }
            
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var logException=  component.get("c.logException");
                            logException.setParams({"error":errors[0].message,"methodName":"triggerSQCheck"});
                            logException.setCallback(this, function(response){
                  });
                  $A.enqueueAction(logException);        
                        }
                    }
                }
                else {                
                    component.set("v.loadingSpinner",false);                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        //EDGE-94105 Changed the message text
                        "title": "Error!",
                        "message":$A.get("$Label.c.SQ_Error"),
                        "type":"error"
                    }); 
                    toastEvent.fire();              
                }        
            });
    $A.enqueueAction(action);            
    }
    })